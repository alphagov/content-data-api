module Audits
  class FindContent
    def self.call(theme_id, page:, organisations:, document_type:, audit_status: nil, primary_org_only:)
      query = Content::Query.new
                .page(page)
                .organisations(organisations, primary_org_only)
                .document_type(document_type)
                .theme(theme_id)

      Audits::ContentQuery.new(scope: query.scope)
        .audit_status(audit_status)
        .content_items
    end
  end
end
