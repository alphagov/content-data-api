class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # Raise ActionController::UnpermittedParameters if there are unpermitted
  # parameters, so we can return better errors for invalid API requests
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
end
