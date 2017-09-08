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
        rows.each { |row| csv << [nil, nil, *row] }
      end
    end

  private

    def headers
      [
        "Report URL",
        "Report timestamp",
        "Title",
        "URL",
        "Is work needed?",
        "Pageviews (last 6 months)",
        "Change title",
        "Change description",
        "Change body",
        "Change attachments",
        "Change document type",
        "Outdated",
        "Remove",
        "Similar",
        "Similar URLs",
        "Notes",
        "Primary organisation",
        "Other organisations",
        "Content type",
        "Last major update",
        "Whitehall URL",
      ]
    end

    def rows
      content_items
        .joins(:report_row)
        .unscope(:order)
        .pluck(:data)
    end

    def report_timestamp
      format_datetime(DateTime.now, relative: false)
    end
  end
end
