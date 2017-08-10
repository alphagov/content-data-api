class Content::ItemsController < ApplicationController
  helper_method :filter_params, :primary_org_only?

  def index
    @metrics = Performance::MetricBuilder.new.run_collection(search.all_content_items)
    @content_items = Content::ItemsDecorator.new(search.content_items)
  end

  def show
    @content_item = Content::Item.find_by!(content_id: params[:content_id]).decorate
  end

private

  def search
    @search ||= Content::Query.new
      .organisations(params[:organisations], primary_org_only?)
      .taxons(params[:taxons])
      .sort(params[:sort])
      .sort_direction(params[:order])
      .title(params[:query])
      .page(params[:page])
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
