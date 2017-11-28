class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery unless: -> { request.format.json? }
  before_action :authenticate_user!
end
