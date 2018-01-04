class Content::LivePagesReportsController < ApplicationController
  def show
    @live_pages = Facts::Metric
                    .by_date_name
                    .count
  end
end
