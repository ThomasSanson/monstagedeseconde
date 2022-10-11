# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferConsumer < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :visitor_query,
        Users::Employer.name => :visitor_query,
        Users::Visitor.name => :visitor_query,
        Users::SchoolManagement.name => :school_management_query,
        Users::Student.name => :school_members_query,
        Users::Statistician.name => :statistician_query,
        Users::MinistryStatistician.name => :ministry_statistician_query,
        Users::God.name => :visitor_query
      }
    end

    private

    def kept_published_future_offers_query
      InternshipOffer.kept
                     .published
                     .in_the_future
    end

    def school_management_query
      common_filter do
        kept_published_future_offers_query.ignore_internship_restricted_to_other_schools(
          school_id: user.school_id
        )
      end
    end

    def school_members_query
      @params = implicit_conditions(params: @params, user: user)
      school_management_query.ignore_already_applied(user: user)
    end

    def statistician_query
      visitor_query.tap do |query|
        query.merge(query.limited_to_department(user: user)) if user.department
      end
    end

    def ministry_statistician_query
      visitor_query.limited_to_ministry(user: user)
    end

    def visitor_query
      common_filter { kept_published_future_offers_query}
    end

    def implicit_conditions(params: , user: )
      if user.student? && user&.class_room.present?
        params.merge!(school_track: user.school_track)
      end
      params
    end
  end
end
