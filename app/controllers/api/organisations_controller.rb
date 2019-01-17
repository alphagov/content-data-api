class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Finders::AllOrganisations.retrieve
    render json: @organisations
  end
end
