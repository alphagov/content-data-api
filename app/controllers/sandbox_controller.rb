class SandboxController < ApplicationController
  def index
    @summary = Facts::Metric
      .joins(:dimensions_item)
      .between(from, to)
      .by_base_path(base_path)
      .metric_summary
  end

private

  def from
    params[:from] ||= 5.days.ago.to_date
  end

  def to
    params[:to] ||= Date.yesterday
  end

  def base_path
    params[:base_path]
  end
end
