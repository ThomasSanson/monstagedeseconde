# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class UserTypableInternshipOffer
    MappingUserTypeWithScope = {
      Users::SchoolManagement.name => :school_members_query,
      Users::Student.name => :school_members_query,
      Users::Employer.name => :employer_query,
      Users::Operator.name => :operator_query,
      Users::Statistician.name => :statistician_query,
      Users::Visitor.name => :visitor_query,
      Users::God.name => :god_query
    }.freeze

    def base_query
      send(MappingUserTypeWithScope.fetch(user.type))
        .group(:id)
        .page(params[:page])
    end

    private

    attr_reader :user, :params

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def nearby_query_part(query, coordinates)
      query.nearby(latitude: coordinates.latitude,
                   longitude: coordinates.longitude,
                   radius: radius_params)
           .with_distance_from(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    end

    # school_members gather students and other profiles/roles
    def school_members_query
      query = InternshipOffer.all

      if user.try(:class_room).try(:troisieme_generale?)
        unless user.missing_school_weeks?
          query = query.merge(
            InternshipOffers::WeeklyFramed.internship_offers_overlaping_school_weeks(weeks: user.school.weeks)
          )
        end
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_already_applied(user: user))
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_max_candidates_reached)
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_max_internship_offer_weeks_reached)

      elsif user.try(:class_room).try(:professional_school_track?)
        query = query.merge(InternshipOffers::FreeDate.ignore_already_applied(user: user))
      end

      query = common_filter do
        query.kept
             .in_the_future
             .published
             .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      end
      query = user_school_track_query(query, user) if user.is_a?(Users::Student)
      query
    end

    def employer_query
      common_filter do
        user.internship_offers.kept
      end
    end

    def operator_query
      query = common_filter do
        InternshipOffer.kept.submitted_by_operator(user: user)
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name.present?
      query
    end

    def statistician_query
      query = common_filter do
        InternshipOffer.kept
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name
      query
    end

    def visitor_query
      common_filter do
        InternshipOffer.kept.in_the_future.published
      end
    end

    def god_query
      common_filter do
        InternshipOffer.kept
      end
    end

    def school_track_param
      return nil unless params.key?(:school_track)

      params[:school_track]
    end

    def keyword_params
      return nil unless params.key?(:keyword)

      params[:keyword]
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)

      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)

      params[:radius]
    end

    def common_filter
      query = yield
      query = keyword_query(query) if keyword_params
      query = nearby_query(query) if coordinate_params
      query = school_track_query(query) if school_track_param
      query
    end

    def keyword_query(query)
      query.merge(InternshipOffer.search_by_keyword(params[:keyword]).group(:rank))
    end

    def nearby_query(query)
      query.merge(nearby_query_part(query, coordinate_params))
    end

    def school_track_query(query)
      query.merge(InternshipOffer.where(school_track: school_track_param))
    end

    def user_school_track_query(query, user)
      return query if user.has_no_class_room?

      query.merge(InternshipOffer.where(school_track: user&.school_track))
    end
  end
end
