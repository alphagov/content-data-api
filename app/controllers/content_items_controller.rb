class ContentItemsController < ApplicationController
  before_action :set_organisation, only: :index

  def index
    @content_items = ContentItemsQuery.build(
      sort: params[:sort],
      order: params[:order],
      query: params[:query],
      page: params[:page],
      organisation: @organisation
    )
  end

  def show
    @content_item = ContentItem.find(params[:id])
  end

private

  def set_organisation
    @organisation = Organisation.find_by_slug(params[:organisation_slug]) if params[:organisation_slug]
  end
end
