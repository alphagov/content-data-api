module Audits
  class FindContent
    def self.call(filter = Filter.new)
      scope = Content::Query.new
                .page(filter.page)
                .organisations(filter.organisations, filter.primary_org_only)
                .document_type(filter.document_type)
                .after(filter.after)
                .theme(filter.theme_id)
                .scope

      filter.audited_policy.call(scope)
    end
  end
end
