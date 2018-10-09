class OrganisationController < Api::BaseController
  def index
    @organisations = Reports::Organisation.retrieve
  end
end
