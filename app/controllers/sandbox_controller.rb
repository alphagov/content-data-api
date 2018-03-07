class SandboxController < ApplicationController
  def index
    @metrics = Facts::Metric
      .joins(:dimensions_item)
      .between(from, to)
      .by_base_path(base_path)

    respond_to do |format|
      format.html { @summary = @metrics.metric_summary }
      format.csv { stream_data_as_csv(@metrics) }
    end
  end

private

  def stream_data_as_csv(scope)
    set_file_headers
    set_streaming_headers

    response.status = 200

    self.response_body = enumerator_of_csv_lines(scope)
  end

  def enumerator_of_csv_lines(scope)
    CSVExport.run(scope, Facts::Metric.csv_fields)
  end

  def set_file_headers
    file_name = "metrics.csv"
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end

  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
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
end
