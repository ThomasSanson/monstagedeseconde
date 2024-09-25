# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = ENV.fetch('WEBINAR_URL').freeze
  layout 'homepage', only: %i[home
                              pro_landing
                              regional_partners_index
                              school_management_landing
                              statistician_landing
                              student_landing
                              search_companies
                              maintenance_estivale]

  def register_to_webinar
    authorize! :subscribe_to_webinar, current_user
    current_user.update(subscribed_to_webinar_at: Time.zone.now)
    redirect_to WEBINAR_URL,
                allow_other_host: true
  end

  def offers_with_sector
    InternshipOffer.includes([:sector])
  end

  def student_landing
    @faqs = get_faqs('student')
  end

  def pro_landing
    @faqs = get_faqs('pro')
  end

  def school_management_landing
    @faqs = get_faqs('education')
  end

  def home
    @faqs = get_faqs('student')
  end

  def maintenance_messaging
    hash = {
      subject: "Message de la page de maintenance de #{user_params[:name]}",
      message: user_params[:message],
      name: user_params[:name],
      email: user_params[:email]
    }

    GodMailer.maintenance_mailing(**hash).deliver_later
    redirect_to '/maintenance_estivale.html', notice: 'Votre message a bien été envoyé'
  end

  def user_params
    params.require(:user).permit(:name, :email, :message)
  end

  private

  def link_resolver
    @link_resolver ||= Prismic::LinkResolver.new(nil) do |link|
      # URL for the category type
      if link.type == 'faq'
        '/faq/' + link.uid
      # Default case for all other types
      else
        '/'
      end
    end
  end

  def get_faqs(tag)
    return [] if ENV['PRISMIC_URL'].blank? || ENV['PRISMIC_API_KEY'].blank? || Rails.env.test?

    api = Prismic.api(ENV['PRISMIC_URL'], ENV['PRISMIC_API_KEY'])

    begin
      response = api.query([
                             Prismic::Predicates.at('document.type', 'faq'),
                             Prismic::Predicates.at('document.tags', [tag])
                           ],
                           { 'orderings' => '[my.faq.order]' })
    rescue StandardError => e
      puts "Error: #{e}"
      return
    end

    serialize_faq(response.results)
  end

  def serialize_faq(results)
    results.map do |doc|
      {
        question: doc['faq.question'].as_text,
        answer: doc['faq.answer'].as_html(link_resolver)
      }
    end
  end
end
