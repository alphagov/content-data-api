class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Finders::AllOrganisations.run
    render json: @organisations
  end
end
