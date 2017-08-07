module Audits
  class Filter
    include ActiveModel::Model
    attr_accessor :theme_id, :page, :organisations, :document_type, :audit_status, :primary_org_only, :after

    def audit_status=(value)
      @audit_status = if value.blank?
                        nil
                      else
                        value.to_sym
                      end
    end

    def audited_policy
      case self.audit_status
      when :audited
        Policies::Audited
      when :non_audited
        Policies::NonAudited
      else
        Policies::AuditedAndNotAudited
      end
    end
  end
end
