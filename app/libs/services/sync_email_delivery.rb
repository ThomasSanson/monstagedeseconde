# frozen_string_literal: true

module Services
  # https://dev.mailjet.com/email/reference/overview/
  class SyncEmailDelivery
    require 'net/https'
    MAILJET_METADATA = [
      {"Datatype"=>"str", "Name"=>"firstname", "NameSpace"=>"static"},
      {"Datatype"=>"str", "Name"=>"name", "NameSpace"=>"static"},
      {"Datatype"=>"str", "Name"=>"role", "NameSpace"=>"static"},
      {"Datatype"=>"int", "Name"=>"monstage_id", "NameSpace"=>"static"},
      {"Datatype"=>"str", "Name"=>"type", "NameSpace"=>"static"},
      {"Datatype"=>"str", "Name"=>"environment", "NameSpace"=>"static"},
      {"Datatype"=>"datetime", "Name"=>"confirmed_at", "NameSpace"=>"static"}
    ].freeze

    MAILJET_HOST = 'https://api.mailjet.com'.freeze

    ENDPOINTS = {
      contact: {
        create: '/v3/REST/contact',
        read: '/v3/REST/contact/%s', # %s -> internpolate monstage.user.email
        destroy: '/v4/contacts/%d',  # %d -> internpolate mailjet.Contact.ID

        metadata: {
          index: '/v3/REST/contactmetadata',
          update: '/v3/REST/contactdata/%s'  # %s -> internpolate monstage.user.email
        }
      }
    }

    # public API
    def create_contact(user:)
      response = send_create_contact(user:user)
      return JSON.parse(response.body) if [201, 401].include?(response.code.to_i)
      raise "fail create_contact: code[#{response.code}], #{response.body}"
    end

    def destroy_contact(email:)
      mailjet_user_id = read_contact(email: email).dig("Data", 0, "ID")
      response = send_destroy_contact(mailjet_user_id: mailjet_user_id)
      return true if [200].include?(response.code.to_i)
      raise "fail destroy_contact: code[#{response.code}], #{response.body}"
    end

    def read_contact(email:)
      response = send_read_contact(email: email)
      return JSON.parse(response.body) if [200].include?(response.code.to_i)
      raise "fail read_contact: code[#{response.code}], #{response.body}"
    end

    def index_contact_metadata
      response = send_index_contact_metadata
      return JSON.parse(response.body) if [200].include?(response.code.to_i)
      raise "fail to index_contact_metadata: code[#{response.code}], #{response.body}"
    end

    def update_contact_metadata(user:)
      response = send_update_contact_metadata(user: user)
      return JSON.parse(response.body) if [200].include?(response.code.to_i)
      raise "fail read_contact: code[#{response.code}], #{response.body}"
    end

    private

    #
    # endpoint requests
    #
    # see: https://dev.mailjet.com/email/reference/contacts/contact#v3_post_contact
    def send_create_contact(user:)
      with_http_connection do |http|
        headers = default_headers.merge({'Content-Type' => 'application/json'})
        request = Net::HTTP::Post.new(ENDPOINTS.dig(:contact, :create), headers)
        data = {
          IsExcludedFromCampaigns: false,
          name: user.name,
          email: user.email
        }
        request.body = data.to_json
        http.request(request)
      end
    end

    # see: https://dev.mailjet.com/email/reference/contacts/contact#v3_send_read_contact_contact_ID
    def send_read_contact(email:)
      with_http_connection do |http|
        request = Net::HTTP::Get.new(ENDPOINTS.dig(:contact, :read) % email, default_headers)
        http.request(request)
      end
    end

    # see: https://stackoverflow.com/questions/50170476/mailjet-delete-contact
    def send_destroy_contact(mailjet_user_id:)
      with_http_connection do |http|
        request = Net::HTTP::Delete.new(ENDPOINTS.dig(:contact, :destroy) % mailjet_user_id, default_headers)
        http.request(request)
      end
    end

    # see: https://dev.mailjet.com/email/reference/contacts/contact-properties#v3_get_contactmetadata
    def send_index_contact_metadata
      with_http_connection do |http|
        request = Net::HTTP::Get.new(ENDPOINTS.dig(:contact, :metadata, :index), default_headers)
        http.request(request)
      end
    end

    # see: https://dev.mailjet.com/email/reference/contacts/contact-properties#v3_put_contactdata_contact_ID
    def send_update_contact_metadata(user:)
      with_http_connection do |http|
        headers = default_headers.merge({'Content-Type' => 'application/json'})
        request = Net::HTTP::Put.new(ENDPOINTS.dig(:contact, :metadata, :update) % user.email, headers)
        data = {
          Data: [
            { Name: "firstname", Value: user.first_name },
            { Name: "name", Value: user.last_name },
            { Name: "role", Value: user.role },
            { Name: "monstage_id", Value: user.id },
            { Name: "type", Value: user.type },
            { Name: "environment", Value: Rails.env },
            { Name: "confirmed_at", Value: user.confirmed_at.utc.to_i }
          ]
        }
        request.body = data.to_json
        http.request(request)
      end
    end

    #
    # utils
    #
    def with_http_connection(&block)
      uri = URI(MAILJET_HOST)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        yield(http)
      end
    end

    # see: https://dev.mailjet.com/email/reference/overview/authentication/
    def default_headers
      user = Credentials.enc(:mailjet, :apikey_public, prefix_env: false)
      pass = Credentials.enc(:mailjet, :apikey_private, prefix_env: false)
      auth = ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)

      {
        'Authorization' => auth,
      }
    end
  end
end
