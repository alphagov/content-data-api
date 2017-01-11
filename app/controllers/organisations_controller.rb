class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all.page(params[:page])
  end
end
