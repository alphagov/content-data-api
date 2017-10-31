module Audits
  class Report
    include FormatHelper

    def self.generate(*args)
      new(*args).generate
    end

    attr_accessor :content_items, :report_url

    def initialize(filter, report_url)
      filter.audit_status = Audit::ALL

      self.content_items = FindContent.all(filter)
      self.report_url = report_url
    end

    def generate
      CSV.generate do |csv|
        csv << headers
        csv << [report_url, report_timestamp]
        rows.each { |row| csv << [nil, nil, *row.values] }
      end
    end

  private

    def headers
      first_row = rows.first || {}
      metadata_headers + first_row.keys
    end

    def metadata_headers
      [
        "Report URL",
        "Report timestamp",
      ]
    end

    def rows
      @rows ||= content_items
        .includes(:audit)
        .includes(:linked_primary_publishing_organisation)
        .includes(:linked_organisations)
        .unscope(:order)
        .map { |item| ReportRow.new(item).to_h }
    end

    def report_timestamp
      format_datetime(DateTime.now, relative: false)
    end
  end
end
