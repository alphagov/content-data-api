class ContentItemsController < ApplicationController
  def index
    @organisation = Organisation.find(params[:organisation_id])
    @content_items = @organisation.content_items.order("#{params[:sort]} #{params[:order]}").first(25)
  end
end
