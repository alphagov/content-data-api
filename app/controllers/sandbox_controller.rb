class SandboxController < ApplicationController
  include Concerns::ExportableToCSV

  def index
    @metrics = Facts::Metric
      .joins(:dimensions_item)
      .by_locale('en')
      .between(from, to)
      .by_base_path(base_path)
      .by_organisation_id(organisation)

    respond_to do |format|
      format.html do
        @summary = @metrics.metric_summary
        @query_params = query_params
      end
      format.csv do
        export_to_csv enum: CSVExport.run(@metrics, Facts::Metric.csv_fields)
      end
    end
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

  def organisation
    params[:organisation]
  end

  def query_params
    params.permit(:from, :to, :base_path, :utf8,
      :total_items, :pageviews, :unique_pageviews, :feedex_issues,
      :number_of_pdfs, :number_of_word_files, :filter, :organisation, :spell_count,
      :readability_score)
  end
end
