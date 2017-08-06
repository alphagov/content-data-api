module Audits
  class FindNextItem
    def self.call(theme_id, page: nil, organisations:, document_type:, audit_status: nil, primary_org_only:, after:)
      FindContent.call(
        theme_id,
        page: page,
        organisations: organisations,
        document_type: document_type,
        audit_status: audit_status,
        primary_org_only: primary_org_only,
        after: after
      ).first
    end
  end
end
