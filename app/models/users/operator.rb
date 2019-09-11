# frozen_string_literal: true

module Users
  class Operator < User
    include UserAdmin
    include InternshipOffersScopes::ByOperator

    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    scope :targeted_internship_offers, lambda { |user:, coordinates:|
      mines_and_sumbmitted_to_operator(user: user)
    }

    before_create :set_api_token

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mes offres'
    end

    private

    def set_api_token
      self.api_token = SecureRandom.uuid
    end
  end
end
