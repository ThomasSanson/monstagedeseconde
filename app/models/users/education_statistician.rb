# frozen_string_literal: true

module Users
  class EducationStatistician < Statistician
    include StatisticianDepartmentable

    # TODO remove relation
    has_one :email_whitelist,
            class_name: 'EmailWhitelists::EducationStatistician',
            foreign_key: :user_id,
            dependent: :destroy

    METABASE_DASHBOARD_ID = 8

    def education_statistician? ; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    rails_admin do
      navigation_label "Référents"
      list do
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        field :department do
          label 'Département'
          pretty_value { bindings[:object]&.department}
        end
        field :statistician_validation do
          label 'Validation'
        end
      end
      
      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :department do
          label 'Département'
        end
        field :statistician_validation do
          label 'Validation'
        end
        field :agreement_signatorable do
          label 'Signataire des conventions'
          help 'Si le V est coché en vert, le signataire doit signer TOUTES les conventions'
        end
      end

      show do
        field :first_name
        field :last_name
        field :email
        field :department do
          label 'Département'
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      export do
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        field :created_at do
          label "Date d'inscription"
          formatted_value {
            I18n.l(bindings[:object].created_at, format: '%d/%m/%Y')
          }
        end
        field :department, :string do
          label 'Département'
          export_value do
            bindings[:object]&.department
          end
        end
        field :statistician_validation do
          label 'Validation'
          export_value do
            bindings[:object].statistician_validation ? 'Validé' : 'En attente'
          end
        end
      end
    end

    private

    # on create, make sure to assign existing email whitelist
    # EmailWhitelists::EducationStatistician holds the user_id foreign key
    def assign_email_whitelist_and_confirm
      # self.email_whitelist = EmailWhitelists::EducationStatistician.find_by(email: email)
      # self.confirmed_at = Time.now
    end

    def email_in_list
      unless EmailWhitelists::EducationStatistician.exists?(email: email)
        errors.add(
          :email,
          'Votre adresse électronique n\'est pas reconnue, veuillez la ' \
          'transmettre à monstagedetroisieme@anct.gouv.fr afin que nous' \
          ' puissions la valider.'
        )
      end
    end
  end
end
