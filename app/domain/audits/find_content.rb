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

      return scope if filter.audit_status.blank?

      if filter.audit_status.to_sym == :audited
        Policies::Audited.call(scope)
      elsif filter.audit_status.to_sym == :non_audited
        Policies::NonAudited.call(scope)
      else
        scope
      end
    end
  end
end
