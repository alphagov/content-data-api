class Api::OrganisationsController < Api::BaseController
  def index
    @organisations = Finders::AllOrganisations.run
    render root: "organisations", json: @organisations
  end
end
