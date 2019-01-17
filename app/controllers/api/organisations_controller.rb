class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Queries::FindAllOrganisations.retrieve
    render json: @organisations
  end
end
