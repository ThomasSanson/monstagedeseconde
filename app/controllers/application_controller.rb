# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Turbo::Redirection

  helper Turbo::FramesHelper if Rails.env.test?
  helper Turbo::StreamsHelper if Rails.env.test?

  before_action :check_for_holidays_maintenance_page
  before_action :check_school_requested
  before_action :check_for_maintenance

  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    return resource.after_sign_in_path if resource.is_a?(Users::God)
    session[:show_student_reminder_modal] = true if resource.needs_to_see_modal?

    stored_location_for(resource) || resource.reload.after_sign_in_path || super
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end

  helper_method :user_presenter, :current_user_or_visitor
  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end

  def check_for_maintenance
    redirect_to '/maintenance.html' if ENV['MAINTENANCE_MODE'] == 'true'
  end

  private

  def check_school_requested
    if current_user && current_user.missing_school?
      redirect_to account_path(:school), flash: {warning: 'Veuillez choisir un établissement scolaire'}
    end
  end

  def check_for_holidays_maintenance_page
    if ENV.fetch('HOLIDAYS_MAINTENANCE', 'false') == 'true' && !maintenance_redirection_exception?
      redirect_to '/maintenance_estivale.html' and return
    end
  end

  def maintenance_redirection_exception?
    allowed_paths = %w[/maintenance_estivale.html /contact.html]
    request.path.in?(allowed_paths) ||
      (request.path == "/maintenance_messaging" && request.post?)
  end
end
