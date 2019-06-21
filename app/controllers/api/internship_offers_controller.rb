# frozen_string_literal: true

module Api

  class InternshipOffersController < ApiBaseController
    before_action :authenticate_api_user!

    rescue_from(ActionController::ParameterMissing) do |error|
      render_error(code: "BAD_PAYLOAD",
                   error: error.message,
                   status: :unprocessable_entity)
    end

    rescue_from(CanCan::AccessDenied) do |error|
      render_error(code: "FORBIDDEN",
                   error: error.message,
                   status: :forbidden)
    end

    def create
      internship_offer_builder.create(params: create_internship_offer_params) do |on|
        on.success do |created_internship_offer|
          render_success(status: :created, object: created_internship_offer)
        end
        on.duplicate do |duplicate_internship_offer|
          render_error(code: "DUPLICATE_INTERNSHIP_OFFER",
                   error: "an object with this remote_id (#{duplicate_internship_offer.remote_id}) already exists for this account",
                   status: :conflict)
        end
        on.failure &method(:render_validation_error)
      end
    end

    def update
      internship_offer = InternshipOffer.find_by!(remote_id: params[:id])

      internship_offer_builder.update(instance: internship_offer,
                                      params: update_internship_offer_params) do |on|
        on.success do |updated_internship_offer|
          render_success(status: :ok, object: updated_internship_offer)
        end
        on.failure &method(:render_validation_error)
      end
    end

    # def destroy
    # end

    private

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_api_user,
                                                        context: :api)
    end

    def create_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :remote_id,
              :permalink,
              :sector_uuid,
              coordinates: {},
              weeks: [],
            )
    end

    def update_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :permalink,
              :sector_uuid,
              coordinates: {},
              weeks: [],
            )
    end
  end
end
