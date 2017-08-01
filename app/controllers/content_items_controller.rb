class ContentItemsController < ApplicationController
  helper_method :filter_params, :primary_org_only?

  def index
    @metrics = Performance::MetricBuilder.new.run_collection(search.unpaginated)
    @content_items = search.content_items.decorate
  end

  def show
    @content_item = ContentItem.find_by(content_id: params[:content_id]).decorate
  end

private

  def search
    @search ||= begin
      query = Content::Query.new
        .organisations(params[:organisations], primary_org_only?)
        .taxons(params[:taxons])
        .sort(params[:sort])
        .sort_direction(params[:order])
        .title(params[:query])
        .page(params[:page])

      Search::Result.new(query.scope)
    end
  end

  def primary_org_only?
    params[:primary].blank? || params[:primary] == "true"
  end

  def filter_params
    request
      .query_parameters
      .deep_symbolize_keys
  end
end
