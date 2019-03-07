class InternshipOffersController < ApplicationController

  def index
    @internship_offers = InternshipOffer.kept.for_user(user: current_user)
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def create
    authorize! :create, InternshipOffer
    @internship_offer = InternshipOffer.new(internship_offer_params)
    @internship_offer.save!
    redirect_to(internship_offer_path(@internship_offer),
                flash: {success: 'Votre annonce a été publiée, vous pouvez la modifier et la supprimer à tout moment'})
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing
    @internship_offer ||= InternshipOffer.new
    find_selectable_content
    render 'internship_offers/new', status: :bad_request
  end

  def edit
    authorize! :update, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    find_selectable_content
  end

  def update
    authorize! :update, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.update!(internship_offer_params)
    redirect_to(@internship_offer,
                flash: { success: 'Votre annonce a bien été modifiée'})
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing => error
    find_selectable_content
    render :edit, status: :bad_request
  end

  def destroy
    authorize! :destroy, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.discard
    redirect_to(root_path,
                flash: { success: 'Votre annonce a bien été supprimée' })
  end

  def new
    authorize! :create, InternshipOffer
    @internship_offer = InternshipOffer.new
    find_selectable_content
  end

  private

  def find_selectable_content
    find_selectable_weeks
  end

  def internship_offer_params
    params.require(:internship_offer)
        .permit(:title, :description, :sector, :can_be_applied_for, :week_day_start, :week_day_end, :excluded_weeks,
                :max_candidates, :max_weeks, :tutor_name, :tutor_phone, :tutor_email, :employer_website,
                :employer_name, :employer_street, :employer_zipcode, :employer_city, :is_public, :group_name,
                operator_names: [], coordinates: {}, week_ids: [])
  end
end
