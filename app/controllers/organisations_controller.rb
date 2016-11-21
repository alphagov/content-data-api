class OrganisationsController < ApplicationController
  def show
    organisation = Organisation.find(params[:id])
    render json: organisation.as_json(only: [:content_id, :number_of_pages])
  end
end
