class Content::ItemsController < ApplicationController
  decorates_assigned :content_item, :content_items
  helper_method :filter_params, :primary_org_only?

  def index
    @metrics = Performance::MetricBuilder.new.run_collection(search.all_content_items)
    @content_items = search.content_items
  end

  def review
    @content_items = Content::Item.where(review_by: Date.today..1.week.from_now).order(:review_by).limit(10)
    render json: @content_items, status: :ok
  end

  def update_review
    @content_item = Content::Item.find_by(content_id: params[:content_id])
    @content_item.review_by = params[:review_by]
    @content_item.save!
    render json: @content_item, status: :ok
  end

  def show
    @content_item = Content::Item.find_by!(content_id: params[:content_id])
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
