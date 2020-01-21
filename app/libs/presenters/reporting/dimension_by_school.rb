module Presenters
  module Reporting
    class DimensionBySchool < BaseDimension
      ATTRS = %i[department
                 code_uai
                 kind]
      METHODS = %i[total_student_count
                   total_main_teacher_count
                   total_approved_internship_applications_count
                   school_manager?
                   full_address
                   full_weeks]


      def self.metrics
        [].concat(ATTRS, METHODS)
      end

      delegate *self.metrics, to: :instance

      def self.dimension_name
        'Etablissement'
      end

      def dimension
        instance.name
      end

      def full_address
        Address.new(instance: instance).to_s
      end

      def full_weeks
        WeekList.new(weeks: instance.weeks).to_s
      end

      private
      attr_reader :instance
      def initialize(instance)
        @instance = instance
      end
    end
  end
end
