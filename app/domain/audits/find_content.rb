module Audits
  class FindContent
    def self.call(theme_id, page: nil, organisations:, document_type:, audit_status: nil, primary_org_only:, after: nil)
      scope = Content::Query.new
                .page(page)
                .organisations(organisations, primary_org_only)
                .document_type(document_type)
                .after(after)
                .theme(theme_id)
                .scope

      return scope if audit_status.blank?

      if audit_status.to_sym == :audited
        Policies::Audited.call(scope)
      elsif audit_status.to_sym == :non_audited
        Policies::NonAudited.call(scope)
      else
        scope
      end
    end
  end
end
