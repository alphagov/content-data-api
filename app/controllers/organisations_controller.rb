class OrganisationsController < ApplicationController
  def index
    render json: Organisation.all.to_json(only: %w(slug))
  end
end
