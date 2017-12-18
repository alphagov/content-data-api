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

      offset = if from_page&.positive?
                 from_page * query.current_per_page - query.current_per_page
               end

      scope = query
                .all_content_items
                .limit(batch_size)
                .offset(offset)

      do_filter!(filter, scope)
    end

    def self.users_unaudited_content(current_user_uid)
      filter = Filter.new(
        allocated_to: current_user_uid,
        audit_status: Audits::Audit::NON_AUDITED
      )
      self.all(filter)
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
        .topics(filter.topics)
        .title(filter.title)
        .document_types(filter.document_type)
        .document_types(*Plan.document_type_ids)
        .sort(filter.sort)
        .sort_direction(filter.sort_direction)
        .after(filter.after)
    end
  end
end
