module Audits
  class Monitor
    attr_accessor :theme_id, :organisations, :document_type, :primary_org_only

    def initialize(theme_id, organisations:, document_type:, primary_org_only:)
      self.theme_id = theme_id
      self.organisations = organisations
      self.document_type = document_type
      self.primary_org_only = primary_org_only
    end

    def total_count
      content_items.total_count
    end

    def audited_count
      Policies::Audited.call(content_items).count
    end

    def not_audited_count
      Policies::NonAudited.call(content_items).count
    end

    def passing_count
      Policies::Passed.call(content_items).count
    end

    def not_passing_count
      Policies::Failed.call(content_items).count
    end

    def audited_percentage
      percentage(audited_count, out_of: total_count)
    end

    def not_audited_percentage
      percentage(not_audited_count, out_of: total_count)
    end

    def passing_percentage
      percentage(passing_count, out_of: audited_count)
    end

    def not_passing_percentage
      percentage(not_passing_count, out_of: audited_count)
    end

  private

    def content_items
      @content_items ||= FindContent.call(
        theme_id,
        organisations: organisations,
        document_type: document_type,
        primary_org_only: primary_org_only,
      )
    end

    def percentage(number, out_of:)
      return 0 if out_of.zero?
      number.to_f / out_of * 100
    end
  end
end
