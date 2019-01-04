class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Organisation.find_all
    render json: @organisations
  end
end
