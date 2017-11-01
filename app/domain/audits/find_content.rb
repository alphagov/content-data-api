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

    def self.batch(filter, from_page:, batch_size:)
      query = query(filter)
      scope = query.all_content_items.limit(batch_size)
      do_filter!(filter, scope)

      if from_page&.positive?
        scope.offset(from_page * query.current_per_page - query.current_per_page)
      else
        scope.offset(from_page)
      end
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
        .title(filter.title)
        .document_types(filter.document_type)
        .document_types(*Plan.document_type_ids)
        .sort(filter.sort)
        .sort_direction(filter.sort_direction)
        .after(filter.after)
    end
  end
end
