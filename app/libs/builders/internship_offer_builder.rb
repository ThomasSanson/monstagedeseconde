# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder < BuilderBase
    # called by dashboard/stepper/practical_info#create during creating with steps
    def create_from_stepper(organisation:, internship_offer_info:, hosting_info:, practical_info:)
      yield callback if block_given?
      authorize :create, model
      internship_offer = model.new(
        {}.merge(preprocess_organisation_to_params(organisation))
          .merge(preprocess_internship_offer_info_to_params(internship_offer_info))
          .merge(preprocess_hosting_info_to_params(hosting_info))
          .merge(preprocess_practical_info_to_params(practical_info))
          .merge(employer_id: user.id, employer_type: 'User')
          .merge(
            organisation_id: organisation.id, 
            internship_offer_info_id: internship_offer_info.id, 
            hosting_info_id: hosting_info.id, 
            practical_info_id: practical_info.id)
        )
        internship_offer.save!
        callback.on_success.try(:call, internship_offer)
      rescue ActiveRecord::RecordInvalid => e
        callback.on_failure.try(:call, e.record)
      end

    # called by internship_offers#create (duplicate), api/internship_offers#create
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      create_params = preprocess_api_params(params, fallback_weeks: true)
      internship_offer = model.create!(create_params)
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      if duplicate?(e.record)
        callback.on_duplicate.try(:call, e.record)
      else
        callback.on_failure.try(:call, e.record)
      end
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.publish! if instance.republish
      instance.attributes = preprocess_api_params(params, fallback_weeks: false)
      instance = deal_with_max_candidates_change(params: params, instance: instance)
      instance.save!
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def discard(instance:)
      yield callback if block_given?
      authorize :discard, instance
      instance.discard!
      callback.on_success.try(:call)
    rescue Discard::RecordNotDiscarded
      callback.on_failure.try(:call, instance)
    end

    private

    attr_reader :callback, :user, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params, fallback_weeks:)
      return params unless from_api?

      opts = { params: params,
               user: user,
               fallback_weeks: fallback_weeks }

      Dto::ApiParamsAdapter.new(opts)
                           .sanitize
    end

    def preprocess_organisation_to_params(organisation)
      {
        employer_name: organisation.employer_name,
        employer_website: organisation.employer_website,
        coordinates: organisation.coordinates,
        street: organisation.street,
        zipcode: organisation.zipcode,
        city: organisation.city,
        employer_description_rich_text: organisation.employer_description,
        is_public: organisation.is_public,
        group_id: organisation.group_id,
        siret: organisation.siret,
        employer_manual_enter: organisation.manual_enter
      }
    end

    def preprocess_internship_offer_info_to_params(internship_offer_info)
      {
        sector_id: internship_offer_info.sector_id,
        title: internship_offer_info.title,
        description_rich_text: (internship_offer_info.description_rich_text.present? ? internship_offer_info.description_rich_text.to_s : internship_offer_info.description),
        type: 'InternshipOfferInfos::WeeklyFramed'
      }
    end

    def preprocess_hosting_info_to_params(hosting_info)
      params = {
        max_candidates: hosting_info.max_candidates,
        max_students_per_group: hosting_info.max_students_per_group,
        school_id: hosting_info.school_id,
        type: 'InternshipOffers::WeeklyFramed'
      }
      params[:week_ids] = hosting_info.week_ids
      params
    end

    def preprocess_practical_info_to_params(practical_info)
      {
        weekly_hours: practical_info.weekly_hours,
        daily_hours: practical_info.daily_hours,
        daily_lunch_break: practical_info.daily_lunch_break,
        weekly_lunch_break: practical_info.weekly_lunch_break,
      }
    end

    def from_api?
      context == :api
    end

    def deal_with_max_candidates_change(params: , instance: )
      return instance unless max_candidates_will_change?(params: params, instance: instance)

      approved_applications_count = instance.internship_applications.approved.count
      former_max_candidates = instance.max_candidates
      next_max_candidates = params[:max_candidates].to_i

      if next_max_candidates < approved_applications_count
        error_message = 'Impossible de réduire le nombre de places ' \
                        'de cette offre de stage car ' \
                        'vous avez déjà accepté plus de candidats que ' \
                        'vous n\'allez leur offrir de places.'
        instance.errors.add(:max_candidates, error_message)
        raise ActiveRecord::RecordInvalid, instance
      end

      instance
    end

    def type_will_change?(params: , instance: )
      params[:type] && params[:type] != instance.type
    end

    def max_candidates_will_change?(params: , instance: )
      params[:max_candidates] && params[:max_candidates] != instance.max_candidates
    end

    def model
      return ::InternshipOffers::Api if from_api?

      InternshipOffers::WeeklyFramed
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id])
        .map { |error| error[:error] }
        .include?(:taken)
    end
  end

end
