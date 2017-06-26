class ReportRow < ApplicationRecord
  include FormatHelper

  belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id

  def self.precompute(content_item)
    find_or_initialize_by(content_item: content_item).precompute
  end

  def precompute
    self.data = [
      title,
      url,
      is_work_needed,
      page_views,
      *response_values,
      primary_organisation,
      other_organisations,
      content_type,
      last_major_update,
      whitehall_url,
    ]

    save!
    self
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

  def response_values
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
    (content_item.document_type || "").titleize
  end

  def last_major_update
    format_datetime(content_item.public_updated_at, relative: false)
  end

  def whitehall_url
    content_item.whitehall_url
  end

private

  def ordered_responses
    questions.map { |q| responses.detect { |r| r.question_id == q.id } }
  end

  def responses
    @responses ||= audit ? audit.responses : []
  end

  def audit
    @audit ||= content_item.audit
  end

  def questions
    @questions ||= Question.order(:id)
  end
end
