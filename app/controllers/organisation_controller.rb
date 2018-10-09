class OrganisationController < Api::BaseController
  def index
    @organisations = Queries::FindAllOrganisations.retrieve
  end
end
