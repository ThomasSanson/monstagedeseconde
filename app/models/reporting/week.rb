# frozen_string_literal: true

module Reporting
  class Week < ApplicationRecord
    include FormatableWeek
    def readonly?
      true
    end

    has_many :school_internship_weeks
    has_many :schools, through: :school_internship_weeks

    scope :school_weeks, lambda {
      Week.selectable_on_school_year
          .select('count(school_id) as school_count_per_week, weeks.id, weeks.number, weeks.year')
          .left_joins(:school_internship_weeks)
          .group('weeks.id')
    }

  end
end
