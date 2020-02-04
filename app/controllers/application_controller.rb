# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Instrumentation::Sentry

  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || resource.after_sign_in_path || super
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end
end
