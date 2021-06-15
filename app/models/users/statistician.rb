# frozen_string_literal: true

module Users
  class Statistician < User
    rails_admin do
      configure :last_sign_in_at, :datetime
      configure :created_at, :datetime

      list do
        field :department
        field :department_zipcode
        fields(*UserAdmin::DEFAULTS_FIELDS)
        field :sign_in_count
        field :last_sign_in_at
        field :created_at
      end
    end

    validate :email_in_list

    has_one :email_whitelist,
            class_name: 'EmailWhitelists::Statistician',
            foreign_key: :user_id,
            dependent: :destroy
    validates :email_whitelist, presence: true
    before_validation :assign_email_whitelist

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: department,
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def custom_dashboard_paths
      [
        url_helpers.reporting_internship_offers_path,
        url_helpers.reporting_schools_path,
        custom_dashboard_path
      ]
    end

    def dashboard_name
      'Statistiques'
    end

    def department
      Department.lookup_by_zipcode(zipcode: department_zipcode)
    end

    def department_zipcode
      email_whitelist&.zipcode
    end

    def destroy
      email_whitelist&.delete 
      super
    end

    private

    # on create, make sure to assign existing email whitelist
    def assign_email_whitelist
      self.email_whitelist = EmailWhitelists::Statistician.find_by(email: email)
    end

    def email_in_list
      errors.add(:email, 'Cette adresse électronique n\'est pas autorisée') unless EmailWhitelists::Statistician.exists?(email: email)
    end
  end
end
