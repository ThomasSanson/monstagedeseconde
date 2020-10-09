# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferPublisher < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :operator_query,
        Users::Employer.name => :employer_query,
      }
    end

    private

    def operator_query
      query = common_filter do
        InternshipOffer.kept.submitted_by_operator(user: user)
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name.present?

      query
    end

    def employer_query
      common_filter do
        query = user.internship_offers.kept

        if school_year_param.present?
          query = query.merge(
            InternshipOffers::WeeklyFramed.specific_school_year(
              school_year: school_year_param
            )
          )
        end

        query
      end
    end

    def school_year_param
      return nil unless params.key?(:school_year)

      params[:school_year].to_i
    end
  end
end
