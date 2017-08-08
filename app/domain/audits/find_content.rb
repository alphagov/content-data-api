module Audits
  class FindContent
    def self.paged(filter)
      scope = query(filter).content_items
      filter.audited_policy.call(scope)
    end

    def self.all(filter)
      scope = query(filter).all_content_items
      filter.audited_policy.call(scope)
    end

    def self.query(filter)
      Content::Query.new
        .page(filter.page)
        .per_page(filter.per_page)
        .organisations(filter.organisations, filter.primary_org_only)
        .document_type(filter.document_type)
        .after(filter.after)
        .theme(filter.theme_id)
    end
  end
end
