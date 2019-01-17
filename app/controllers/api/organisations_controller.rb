class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Finders::FindAllOrganisations.retrieve
    render json: @organisations
  end
end
