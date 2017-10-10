module Audits
  class SerializeFilterToQueryParameters
    def initialize(filter)
      @filter = filter
    end

    def call
      {
        allocated_to: @filter.allocated_to,
        audit_status: @filter.audit_status,
        document_type: @filter.document_type,
        organisations: @filter.organisations,
        primary: @filter.primary_org_only,
        query: @filter.title,
        sort_by: @filter.sort_by,
      }
    end
  end
end
