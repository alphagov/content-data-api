class SandboxController < ApplicationController
  include Concerns::ExportableToCSV

  def index
    report = build_series_report
    @metrics = report.run

    respond_to do |format|
      format.html do
        @content_items = report.content_items
        @query_params = query_params
      end

      format.csv do
        export_to_csv enum: CSVExport.run(@metrics, Facts::Metric.csv_fields)
      end
    end
  end

private

  def build_series_report
    Reports::FindSeries.new
      .between(from: from, to: to)
      .by_base_path(base_path)
      .by_organisation_id(organisation)
      .by_document_type(document_type)
  end

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

  def document_type
    params[:document_type]
  end

  def query_params
    params.permit(:from, :to, :base_path, :utf8, :organisation, :filter,
      :metric1, :metric2, :metric3, :metric, :document_type)
  end
end
