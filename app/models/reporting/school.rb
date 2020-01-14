# frozen_string_literal: true

module Reporting
  # wrap reporting for School
  class School < ApplicationRecord
    PAGE_SIZE = 100

    has_many :users, foreign_type: 'type'
    has_one :school_manager, class_name: 'Users::SchoolManager'
    has_many :teachers, dependent: :nullify,
                        class_name: 'Users::Teacher'


    has_many :school_internship_weeks, dependent: :destroy
    has_many :weeks, through: :school_internship_weeks

    scope :with_school_manager, lambda { joins(:school_manager) }
    scope :without_school_manager, lambda { left_joins(:school_manager) }
    scope :with_teacher_count, lambda {
      left_joins(:teachers)
        .select("schools.*, count(users.id) as teacher_count")
        .group("schools.id")

    }

    paginates_per PAGE_SIZE

    def readonly?
      true
    end

    def students
      users.select{|user| user.is_a?(Users::Student)}
    end

    def total_student_count
      students.size
    end

    def total_student_with_confirmation_count
      students.select{|user| user.confirmed_at?}
              .size
    end

    def total_student_with_parental_consent_count
      students.select{|user| user.has_parental_consent? }
              .size
    end

    def school_manager?
      users.select{|user| user.is_a?(Users::SchoolManager)}
           .size
           .positive?
    end

    def total_main_teacher_count
      users.select{|user| user.is_a?(Users::MainTeacher)}
           .size
    end
  end
end
