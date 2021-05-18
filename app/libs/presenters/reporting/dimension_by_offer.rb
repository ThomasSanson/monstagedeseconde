# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByOffer < BaseDimension
      ATTRS = %i[description
                 human_max_candidates
                 published_at
                 discarded_at
                 submitted_applications_count
                 rejected_applications_count
                 approved_applications_count
                 department
                 academy
                 permalink
                 view_count].freeze
      METHODS = %i[group_name
                   human_is_public
                   sector_name
                   tutor_name
                   tutor_email
                   tutor_phone
                   full_employer
                   full_address
                   full_school
                   full_week].freeze

      def self.metrics
        [].concat(ATTRS, METHODS)
      end

      delegate(*ATTRS, to: :instance)

      def self.dimension_name
        "Titre de l'offre"
      end

      def human_max_candidates
        if instance.max_candidates == 1
          ' Stage individuel (un seul élève par stage)'
        else
          " Stage collectif (par groupe de #{instance.max_candidates} élèves)"
        end
      end

      def human_is_public
        instance.is_public ? 'Public' : 'Privé'
      end

      def dimension
        instance.title
      end

      def sector_name
        instance.sector.name
      end

      def group_name
        instance.group.try(:name) || 'Indépendant'
      end

      def tutor_name
        instance.tutor_name
      end

      def tutor_email
        instance.tutor_email
      end

      def tutor_phone
        instance.tutor_phone
      end

      def full_employer
        [instance.employer_name, instance.employer_website, instance.employer_description].compact.join("\n")
      end

      def full_address
        Address.new(instance: instance).to_s
      end

      def full_school
        return nil unless instance.school

        [instance.school.name, "#{instance.school.city} – CP #{instance.school.zipcode}"].compact.join("\n")
      end

      def full_week(week)
        "Du #{week.beginning_of_week} au #{week.end_of_week}"
      end
    end
  end
end
