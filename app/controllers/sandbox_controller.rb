class SandboxController < ApplicationController
  include Concerns::ExportableToCSV

  def index
    @all_metrics = Metric.find_all.map(&:name)

    @selected_metrics = [
      params[:metric1],
      params[:metric2],
      params[:metric3]
    ]

    respond_to do |format|
      format.html do
        @metrics = Reports::Series.new
          .for_en
          .between(from: from, to: to)
          .by_base_path(base_path)
          .by_organisation_id(organisation)
          .by_document_type(document_type)

        @metrics =
          if is_edition_metric?
            @metrics.with_edition_metrics.run
          else
            @metrics.run
          end

        @query_params = query_params
      end

      format.csv do
        @metrics = Reports::Series.new
          .for_en
          .between(from: from, to: to)
          .by_base_path(base_path)
          .by_organisation_id(organisation)
          .with_edition_metrics
          .run

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

  def document_type
    params[:document_type]
  end

  def query_params
    params.permit(:from, :to, :base_path, :utf8, :organisation, :filter,
      :metric1, :metric2, :metric3, :metric, :document_type)
  end

  def is_edition_metric?
    @selected_metrics.any? { |metric| Metric.is_edition_metric?(metric) }
  end
end
