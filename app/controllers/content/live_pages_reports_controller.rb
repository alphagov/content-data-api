class Content::LivePagesReportsController < ApplicationController
  def show
    @live_pages = Facts::Metric
                    .by_date_name
                    .for_organisation(content_id: filter_params[:organisation])
                    .count
  end

private

  def filter_params
    params.permit(:organisation)
  end
end
