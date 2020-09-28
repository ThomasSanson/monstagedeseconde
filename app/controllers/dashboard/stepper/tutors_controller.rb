# frozen_string_literal: true

module Dashboard::Stepper
  class TutorsController < ApplicationController
    before_action :authenticate_user!

    def new
      authorize! :create, InternshipOffer
      @tutor = Tutor.new
    end

    def create
      @tutor = Tutor.new(tutor_params)
      @tutor.save!
      internship_offer_builder.create_from_stepper(builder_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(internship_offer_path(created_internship_offer),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.' })
        end
        on.failure do |failed_internship_offer|
          render :new, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing => e
      @tutor ||= Tutor.new
      render :new, status: :bad_request
    end

    private

    def builder_params
      {
        tutor: @tutor,
        internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
        organisation: Organisation.find(params[:organisation_id])
      }
    end

    def tutor_params
      params.require(:tutor)
            .permit(:tutor_name, :tutor_phone, :tutor_email)
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end
  end
end
