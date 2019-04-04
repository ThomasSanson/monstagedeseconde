class InternshipApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_internship_offer, only: [:index, :update]

  def index
    @internship_applications = @internship_offer.internship_applications
                                                .order(updated_at: :desc)
                                                .page(params[:page])

    authorize! :read, @internship_offer
    authorize! :index, InternshipApplication
  end

  def create
    @internship_application = InternshipApplication.create(internship_application_params)
    authorize! :apply, InternshipOffer
    if @internship_application.valid?
      EmployerMailer.with(internship_application: @internship_application).new_internship_application_email.deliver_later
      redirect_to internship_offers_path, flash: { success: "Votre candidature a bien été envoyée." }
    else
      @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      redirect_to @internship_offer, flash: { danger: "Erreur dans la saisie de votre candidature" }
    end
  end

  def update
    @internship_application = @internship_offer.internship_applications.find(params[:id])
    authorize! :update, @internship_offer, InternshipApplication
    @internship_application.send(params[:transition]) if valid_transition?
    redirect_to @internship_application.internship_offer, flash: { success: 'Candidature mis à jour avec succès' }
  end

  private

  def valid_transition?
    %w[approve! reject! signed! cancel!].include?(params[:transition])
  end

  def find_internship_offer
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
  end

  def internship_application_params
    params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
  end
end
