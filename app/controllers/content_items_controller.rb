class ContentItemsController < ApplicationController
  before_action :set_organisation, only: :index
  before_action :set_taxonomy, only: :index
  before_action :set_query_options, only: :index
  before_action :set_all_organisations, only: :index
  before_action :set_all_taxonomies, only: :index

  def index
    query = ContentItemsQuery.new(@query_options)
    @content_items = query.paginated_results.decorate
    @metrics = MetricBuilder.new.run_collection(query.results)
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end

private

  def set_query_options
    @query_options = {
      sort: params[:sort],
      order: params[:order],
      query: params[:query],
      page: params[:page],
      taxonomy: @taxonomy,
      organisation: @organisation
    }
  end

  def set_all_organisations
    @organisations = Organisation.order(:title)
  end

  def set_all_taxonomies
    @taxonomies = Taxonomy.order(:title)
  end

  def set_organisation
    @organisation = Organisation.find_by(content_id: params[:organisation_id]) if params[:organisation_id]
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find_by(content_id: params[:taxonomy_content_id]) if params[:taxonomy_content_id]
  end
end
