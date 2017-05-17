class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
