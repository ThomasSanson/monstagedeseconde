# frozen_string_literal: true

module TargetableInternshipOffersForSchool
  extend ActiveSupport::Concern

  included do
    include InternshipOffersScopes::ByCoordinates
    include InternshipOffersScopes::BySchool
    include InternshipOffersScopes::ByWeeks
    include InternshipOffersScopes::ByMaxWeeks
    include InternshipOffersScopes::ByMaxCandidates

    scope :targeted_internship_offers, lambda { |user:|
      query = InternshipOffer.kept
      query = query.merge(internship_offers_nearby_from_school(coordinates: user.school.coordinates)) if user.school
      query = query.merge(internship_offers_overlaping_school_weeks(weeks: user.school.weeks)) if user.school
      query = query.merge(ignore_internship_restricted_to_other_schools(school_id: user.school_id))
      query = query.merge(ignore_max_candidates_reached)
      query = query.merge(ignore_max_internship_week_number_reached)
      query
    }
  end
end
