# frozen_string_literal: true

module Dashboard::Stepper
  # Step 2 of internship offer creation: fill in offer details/info
  class InternshipOfferInfosController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_internship_offer_info, only: %i[edit update]

    # render step 2
    def new
      authorize! :create, InternshipOfferInfo

      @internship_offer_info = InternshipOfferInfo.new
      @organisation = Organisation.find(params[:organisation_id])
    end

    # process step 2
    def create
      authorize! :create, InternshipOfferInfo
      @internship_offer_info = InternshipOfferInfo.new(
        {}.merge(internship_offer_info_params)
          .merge(employer_id: current_user.id)
      )
      @internship_offer_info.save!
      redirect_to(new_dashboard_stepper_hosting_info_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: @internship_offer_info.id
      ))
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      render :new, status: :bad_request
    end

    # render back to step 2
    def edit
      authorize! :edit, @internship_offer_info
      @organisation = Organisation.find(params[:organisation_id])
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      authorize! :update, @internship_offer_info

      if @internship_offer_info.update(internship_offer_info_params)
        if params[:hosting_info_id].present? && HostingInfo.find(params[:hosting_info_id])
          redirect_to edit_dashboard_stepper_hosting_info_path(
            organisation_id: params[:organisation_id],
            internship_offer_info_id: @internship_offer_info.id,
            practical_info_id: params[:practical_info_id],
            id: params[:hosting_info_id]
          )
        else
          redirect_to new_dashboard_stepper_hosting_info_path(
            organisation_id: params[:organisation_id],
            internship_offer_info_id: @internship_offer_info.id
          )
        end
      else
        @organisation = Organisation.find(params[:organisation_id])
        render :new, status: :bad_request
      end
    end

    private

    def internship_offer_info_params
      params.require(:internship_offer_info)
            .permit(
              :title,
              :employer_type,
              :type,
              :sector_id,
              :school_id,
              :employer_id,
              :description_rich_text,
              :max_candidates,
              :siret,
              week_ids: []
              )
    end

    def fetch_internship_offer_info
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
    end
  end
end
