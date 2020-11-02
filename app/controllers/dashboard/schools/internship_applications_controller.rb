# frozen_string_literal: true

module Dashboard
  module Schools
    class InternshipApplicationsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_internship_agreements, @school
        @applications_by_class_room = @school.internship_applications.approved.group_by { |application| Presenters::ClassRoom.or_null(application.student.class_room) }
      end
    end
  end
end
