class ContentItemsController < ApplicationController
  helper_method :filter_params, :primary_org_only?, :org_link_type

  def index
    @search = Search.new
    filter_by_organisation!(@search)
    filter_by_taxon!(@search)
    sort!(@search)
    @search.title = params[:query] if params[:query]
    @search.page = params[:page]
    @search.execute

    @metrics = MetricBuilder.new.run_collection(@search.unpaginated)

    @content_items = @search.content_items.decorate
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end

private

  def filter_by_organisation!(search)
    content_id = params[:organisations]
    search.filter_by(link_type: org_link_type, target_ids: content_id) if content_id.present?
  end

  def sort!(search)
    if params[:order].present? && params[:sort].present?
      search.sort = "#{params[:sort]}_#{params[:order]}".to_sym
    end
  end

  def filter_by_taxon!(search)
    content_id = params[:taxons]
    search.filter_by(link_type: "taxons", target_ids: content_id) if content_id.present?
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
