class OrganisationsController < ApplicationController
  def index
    render json: Organisation.all.to_json(only: [:slug], methods: [:total_content_items])
  end
end
