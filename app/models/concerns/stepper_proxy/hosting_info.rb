# frozen_string_literal: true

module StepperProxy
  module HostingInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      # Validations
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }
      validates :max_students_per_group,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: :max_candidates ,
                                message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }
      
      enum period: {
        0 => 'full_time',
        1 => 'week_1',
        2 => 'week_2'
      }
      attribute :period, :integer, default: 0

      def is_individual?
        max_students_per_group == 1
      end

      def init
        self.max_candidates ||= 1
        self.max_students_per_group ||= 1
      end
    end
  end
end
