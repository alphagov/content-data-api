class ContentItemsController < ApplicationController
  helper_method :filter_params, :primary_org_only?, :org_link_type

  def index
    search.filter_by(link_type: org_link_type, target_ids: params[:organisations]) if params[:organisations].present?
    search.filter_by(link_type: "taxons", target_ids: params[:taxons]) if params[:taxons].present?
    search.sort = params[:sort].to_sym if params[:sort].present?
    search.sort_direction = params[:order] if params[:order].present?
    search.title = params[:query] if params[:query]
    search.page = params[:page]
    search.execute

    @metrics = Performance::MetricBuilder.new.run_collection(search.unpaginated)

    @content_items = search.content_items.decorate
  end

  def show
    @content_item = ContentItem.find_by(content_id: params[:content_id]).decorate
  end

private

  def search
    @search ||= Search.new
  end

  def org_link_type
    primary_org_only? ? Link::PRIMARY_ORG : Link::ALL_ORGS
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
