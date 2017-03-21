class ContentItemsController < ApplicationController
  before_action :set_organisation, only: :index
  before_action :set_taxonomy, only: :index

  def index
    @content_items = ContentItemsQuery.build(
      sort: params[:sort],
      order: params[:order],
      query: params[:query],
      page: params[:page],
      taxonomy: @taxonomy,
      organisation: @organisation
    ).decorate
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end

  def filter
    @organisations = Organisation.order(:title)
    @taxonomies = Taxonomy.order(:title)
  end

private

  def set_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug]) if params[:organisation_slug]
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find_by(content_id: params[:taxonomy_content_id]) if params[:taxonomy_content_id]
  end
end
