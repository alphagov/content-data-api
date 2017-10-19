module Audits
  class ReportRow < ApplicationRecord
    include FormatHelper

    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id,
               class_name: 'Content::Item'

    def self.precompute(content_item)
      find_or_initialize_by(content_item: content_item).precompute
    end

    def precompute
      self.data = {
        "Title" => title,
        "URL" => url,
        "Is work needed?" => is_work_needed,
        "Pageviews (last 6 months)" => page_views,
        "Change title" => audit&.change_title,
        "Change description" => audit&.change_description,
        "Change body" => audit&.change_body,
        "Change attachments" => audit&.change_attachments,
        "Change content type" => audit&.reformat,
        "Outdated" => audit&.outdated,
        "Remove" => audit&.redundant,
        "Similar" => audit&.similar,
        "Similar URLs" => audit&.similar_urls,
        "Notes" => audit&.notes,
        "Primary organisation" => primary_organisation,
        "Other organisations" => other_organisations,
        "Content type" => content_type,
        "Last major update" => last_major_update,
        "Whitehall URL" => whitehall_url,
      }

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

    def primary_organisation
      primary = content_item.linked_primary_publishing_organisation.first
      primary.title if primary
    end

    def other_organisations
      organisations = content_item.linked_organisations
      others = organisations.map(&:title).sort - [primary_organisation]

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

    def audit
      @audit ||= content_item.audit
    end
  end
end
