# frozen_string_literal: true

module Dashboard
  module Schools
    class UsersController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_users, @school
      end

      def destroy
        user = @school.users.find(params[:id])
        user_presenter = Presenters::User.new(user: user)
        authorize! :delete, user
        user.update!(school_id: nil)
        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Le #{user_presenter.role_name} #{user_presenter.short_name} a bien été supprimé de votre collège" }
      rescue ActiveRecord::RecordInvalid
        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Une erreur est survenue, impossible de supprimé #{user_presenter.human_role} #{user_presenter.short_name} de votre collège: #{e.record.full_messages}" }
      end

      def update
        user = @school.users.find(params[:id])

        authorize! :update, user
        user.update!(user_params)

        flash_content = {}
        if params[:user][:has_parental_consent] == 'true'
          flash_content = { success: "Le compte de #{user.name} a bien été autorisé" }
          StudentMailer.account_activated_by_main_teacher_email(user: user).deliver_later
        end

        redirect_back fallback_location: root_path, flash: flash_content
      rescue ActiveRecord::RecordInvalid
        redirect_back fallback_location: root_path, status: :bad_request
      end

      private

      def user_params
        params.require(:user).permit(:has_parental_consent, :custom_track)
      end
    end
  end
end
