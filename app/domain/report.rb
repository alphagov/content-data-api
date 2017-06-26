class Report
  include FormatHelper

  def self.generate(*args)
    new(*args).generate
  end

  attr_accessor :content_items, :request, :questions

  def initialize(content_items, request)
    self.content_items = preload(content_items)
    self.request = request
    self.questions = Question.order(:id).to_a
  end

  def generate
    CSV.generate do |csv|
      csv << headers
      csv << [report_url, report_timestamp]
      content_items.each { |c| csv << Row.for(c, questions) }
    end
  end

private

  def preload(content_items)
    associations = [
      { audit: [:user, :responses] },
      :linked_organisations,
      :linked_primary_publishing_organisation,
    ]

    content_items.includes(associations).references(associations).to_a
  end

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

  def report_url
    request.url
  end

  def report_timestamp
    format_datetime(DateTime.now, relative: false)
  end

  class Row
    include FormatHelper

    def self.for(*args)
      new(*args).to_a
    end

    attr_accessor :content_item, :questions

    def initialize(content_item, questions)
      self.content_item = content_item
      self.questions = questions
    end

    def to_a
      [
        nil,
        nil,
        title,
        url,
        is_work_needed,
        page_views,
        *responses,
        primary_organisation,
        other_organisations,
        content_type,
        last_major_update,
        whitehall_url,
      ]
    end

    def title
      content_item.title
    end

    def url
      content_item.url
    end

    def is_work_needed
      format_boolean(audit.failing?) if audit
    end

    def page_views
      format_number(content_item.six_months_page_views)
    end

    def responses
      ordered_responses.map do |response|
        next unless response

        if response.boolean?
          format_boolean(response.passing?)
        else
          response.value
        end
      end
    end

    def primary_organisation
      primary = content_item.linked_primary_publishing_organisation.first
      primary.title if primary
    end

    def other_organisations
      organisations = content_item.linked_organisations
      others = organisations.map(&:title) - [primary_organisation]

      others.join(", ")
    end

    def content_type
      content_item.document_type.titleize
    end

    def last_major_update
      format_datetime(content_item.public_updated_at, relative: false)
    end

    def whitehall_url
      content_item.whitehall_url
    end

  private

    def audit
      content_item.audit
    end

    def ordered_responses
      responses = audit ? audit.responses : []
      questions.map { |q| responses.detect { |r| r.question_id == q.id } }
    end

    def user
      audit.user if audit
    end
  end
end
