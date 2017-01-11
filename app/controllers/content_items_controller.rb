class ContentItemsController < ApplicationController
  def index
    @organisation = Organisation.find_by_slug(params[:organisation_slug])
    @content_items = @organisation.content_items.order("#{params[:sort]} #{params[:order]}").page(params[:page])
  end

  def show
    @content_item = ContentItem.find(params[:id])
    @organisation = Organisation.find_by_slug(params[:organisation_slug])
  end
end
