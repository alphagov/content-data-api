module Audits
  class Filter
    include ActiveModel::Model
    attr_accessor :after,
      :allocated_to,
      :audit_status,
      :document_type,
      :organisations,
      :page,
      :per_page,
      :primary_org_only,
      :theme_id

    def audit_status=(value)
      @audit_status = if value.blank?
                        nil
                      else
                        value.to_sym
                      end
    end

    def allocated_policy
      if allocated_to == 'no_one'
        Policies::Unallocated
      elsif allocated_to.blank?
        Policies::AllocatedAndUnallocated
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
