module Audits
  class Filter
    include ActiveModel::Model
    attr_accessor :theme_id, :page, :per_page, :organisations, :document_type, :audit_status, :primary_org_only, :after, :allocated_to

    def audit_status=(value)
      @audit_status = if value.blank?
                        nil
                      else
                        value.to_sym
                      end
    end

    def allocated_policy
      if allocated_to == 'no_one'
        Policies::NonAllocated
      elsif allocated_to.blank?
        Policies::AllocatedAndNonAllocated
      else
        Policies::Allocated
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
