module Dashboard
  # WIP, not yet implemented, will host agreement signing
  class InternshipAgreementsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_internship_agreement, only: %i[edit update show]

    def new
      @internship_agreement = internship_agreement_builder.new_from_application(
        InternshipApplication.find(params[:internship_application_id])
      )
    end

    def create
      internship_agreement_builder.create(params: internship_agreement_params) do |on|
        on.success do |created_internship_agreement|
          redirect_to current_user.custom_agreements_path,
                      flash: { success: 'La convention a été créée.' }
        end
        on.failure do |failed_internship_agreement|
          @internship_agreement = failed_internship_agreement || InternshipAgreement.new(
            internship_application_id: params[:internship_application_id]
          )
          render :new, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing => e
      @internship_agreement = InternshipAgreement.new(
        internship_application_id: params[:internship_application_id]
      )
      render :new, status: :bad_request
    end

    def edit
      authorize! :update, @internship_agreement
    end

    def update
      authorize! :update, @internship_agreement
      internship_agreement_builder.update(instance: @internship_agreement,
                                          params: internship_agreement_params) do |on|
        on.success do |updated_internship_agreement|
          updated_internship_agreement = process_state_update(
            agreement: updated_internship_agreement,
            params: params
          )
          updated_internship_agreement.save
          redirect_to dashboard_internship_agreements_path, flash: { success: update_success_message(updated_internship_agreement) }
        end
        on.failure do |failed_internship_agreement|
          @internship_agreement = failed_internship_agreement || InternshipAgreement.find(params[:id])
          render :edit
        end
      end
    rescue ActionController::ParameterMissing => e
      @internship_agreement = InternshipAgreement.find(params[:id])
      render :edit
    end

    def show
      authorize! :update, @internship_agreement
      respond_to do |format|
        format.html
        format.pdf do
          ext_file_name = @internship_agreement.internship_application
                                               .student
                                               .presenter
                                               .full_name_camel_case
          send_data(
            GenerateInternshipAgreement.new(@internship_agreement.id).call.render,
              filename: "Convention_de_stage_#{ext_file_name}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
          ) && @internship_agreement.signatures.each do |signature|
              signature.config_clean_local_signature_file
            end
        end
      end
    end

    def index
      authorize! :index, InternshipAgreement
      if current_user.employer_like?
        @internship_offers = current_user.internship_offers
      end
      @internship_agreements = current_user.internship_agreements
                                           .filtering_discarded_students
                                           .kept
                                           .includes(
                                              internship_application: [
                                                { student: :school },
                                                { internship_offer: [:employer]}
                                                ]
                                              )
                                          #  .reject { |a| a.student.school.school_manager.nil? }
      @school = current_user.school if current_user.school_management?
      @no_agreement_internship_application_list = []
                                                    # current_user.internship_applications
                                                    #           .filtering_discarded_students
                                                    #           .approved
                                                    #           .select { |ia| ia.student.school.school_manager.nil? }
    end

    private

    def internship_agreement_params
      params.require(:internship_agreement)
            .permit(
              :internship_application_id,
              :student_school,
              :school_representative_email,
              :school_representative_full_name,
              :school_representative_function,
              :school_representative_phone,
              :school_representative_role,
              :delegation_date,
              :legal_status,
              :student_full_name,
              :student_class_room,
              :organisation_representative_full_name,
              :organisation_representative_role,
              :date_range,
              :doc_date,
              :schedule_rich_text,
              :activity_scope_rich_text,
              :activity_preparation_rich_text,
              :activity_learnings_rich_text,
              :activity_rating_rich_text,
              :skills_observe_rich_text,
              :skills_communicate_rich_text,
              :skills_understand_rich_text,
              :skilles_motivation_rich_text,
              :legal_terms_rich_text,
              :school_manager_accept_terms,
              :employer_accept_terms,
              :employer_event,
              :employer_name,
              :internship_address,
              :employer_contact_email,
              :school_manager_event,
              :main_teacher_accept_terms,
              :student_refering_teacher_full_name,
              :student_refering_teacher_email,
              :student_refering_teacher_phone,
              :student_address,
              :student_phone,
              :student_legal_representative_full_name,
              :student_legal_representative_email,
              :student_legal_representative_phone,
              :student_legal_representative_2_full_name,
              :student_legal_representative_2_email,
              :student_legal_representative_2_phone,
              :siret,
              :tutor_full_name,
              :tutor_role,
              :tutor_email,
              :lunch_break,
              :weekly_lunch_break,
              weekly_hours:[],
              daily_hours:{},
              )
    end

    def internship_agreement_builder
      @builder ||= Builders::InternshipAgreementBuilder.new(user: current_user)
    end

    def update_success_message(internship_agreement)
      case internship_agreement.aasm_state
      when 'started_by_employer' then 'La convention a été enregistrée.'
      when 'completed_by_employer' then "La convention a été envoyée au chef d'établissement."
      when 'started_by_school_manager' then 'La convention a été enregistrée.'
      when 'validated' then "La convention est validée, le fichier pdf de la convention est maintenant disponible."
      else
        'La convention a été enregistrée.'
      end
    end

    def process_state_update( agreement: , params: )
      employer_event       = params[:internship_agreement][:employer_event]
      school_manager_event = params[:internship_agreement][:school_manager_event]
      return agreement if employer_event.blank? && school_manager_event.blank?

      agreement = transit_when_allowed( agreement: agreement, event: employer_event )
      agreement = transit_when_allowed( agreement: agreement, event: school_manager_event )
      agreement
    end

    def transit_when_allowed(agreement: , event:)
      return agreement if event.blank?
      return agreement unless agreement.send("may_#{event}?")

      agreement.send(event)
      agreement
    end

    def set_internship_agreement
      @internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
    end
  end
end
