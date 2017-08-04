module Audits
  class Monitor
    attr_accessor :theme_id, :organisations, :document_type, :primary_org_only

    def initialize(theme_id, organisations:, document_type:, primary_org_only:)
      self.theme_id = theme_id
      self.organisations = organisations
      self.document_type = document_type
      self.primary_org_only = primary_org_only
    end

    def query
      @query ||= Content::Query.new
                   .organisations(organisations, primary_org_only)
                   .document_type(document_type)
                   .theme(theme_id)
    end

    def total_count
      query.content_items.total_count
    end

    def audited_count
      Audits::ContentQuery
        .new(scope: query.scope)
        .audited
        .content_items
        .total_count
    end

    def not_audited_count
      Audits::ContentQuery
        .new(scope: query.scope)
        .non_audited
        .content_items
        .total_count
    end

    def audited_percentage
      percentage(audited_count, out_of: query.content_items.total_count)
    end

    def not_audited_percentage
      percentage(not_audited_count, out_of: query.content_items.total_count)
    end

    def passing_count
      Audits::ContentQuery
        .new(scope: query.scope)
        .passing
        .content_items
        .total_count
    end

    def not_passing_count
      Audits::ContentQuery
        .new(scope: query.scope)
        .failing
        .content_items
        .total_count
    end

    def passing_percentage
      percentage(passing_count, out_of: audited_count)
    end

    def not_passing_percentage
      percentage(not_passing_count, out_of: audited_count)
    end

  private

    def percentage(number, out_of:)
      return 0 if out_of.zero?
      number.to_f / out_of * 100
    end
  end
end
