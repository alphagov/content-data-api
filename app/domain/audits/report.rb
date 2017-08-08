module Audits
  class Report
    include FormatHelper

    def self.generate(*args)
      new(*args).generate
    end

    attr_accessor :content_items, :report_url, :questions

    def initialize(filter, report_url)
      filter.audit_status = nil

      self.content_items = FindContent.all(filter)
      self.report_url = report_url
      self.questions = Question.order(:id).to_a
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
        *questions.map(&:text),
        "Primary organisation",
        "Other organisations",
        "Content type",
        "Last major update",
        "Whitehall URL",
      ]
    end

    def rows
      content_items.joins(:report_row).pluck(:data)
    end

    def report_timestamp
      format_datetime(DateTime.now, relative: false)
    end
  end
end
