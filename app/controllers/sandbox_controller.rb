class SandboxController < ApplicationController
  def index
    @metrics = Facts::Metric
              .joins(:dimensions_item)
              .between(from, to)
              .by_base_path(base_path)

    @summary = @metrics.metric_summary
    @number_of_pdfs = @metrics.sum(:number_of_pdfs)
    @number_of_word_files = @metrics.sum(:number_of_word_files)
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
