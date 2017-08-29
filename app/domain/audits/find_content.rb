module Audits
  class FindContent
    def self.paged(filter)
      scope = query(filter).content_items
      do_filter!(filter, scope)
    end

    def self.all(filter)
      scope = query(filter).all_content_items
      do_filter!(filter, scope)
    end

    def self.do_filter!(filter, scope)
      scope = filter.audited_policy.call(scope)
      filter.allocated_policy.call(scope, allocated_to: filter.allocated_to)
    end

    def self.query(filter)
      Content::Query.new
        .page(filter.page)
        .per_page(filter.per_page)
        .organisations(filter.organisations, filter.primary_org_only)
        .document_types(filter.document_type)
        .sort(filter.sort)
        .sort_direction(filter.sort_direction)
        .after(filter.after)
        .theme(filter.theme_id)
    end
  end
end
