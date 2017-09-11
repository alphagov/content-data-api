module Audits
  class Filter
    include ActiveModel::Model
    attr_accessor :after,
      :allocated_to,
      :audit_status,
      :current_user_id,
      :document_type,
      :organisations,
      :page,
      :per_page,
      :primary_org_only,
      :sort,
      :sort_direction,
      :theme_id,
      :title

    def audit_status=(value)
      @audit_status = value.to_sym unless value.blank?
    end

    def audit_status
      @audit_status || Audit::ALLOCATED_TO
    end

    def sort_by=(value)
      if value.present?
        raise "Invalid value: #{value}" unless value =~ /\A[a-z]+_(asc|desc)\z/

        values = value.split("_")
        self.sort = values[0]
        self.sort_direction = values[1]
      end
    end

    def allocated_policy
      if allocated_to.blank?
        @allocated_to = current_user_id
        Policies::Allocated
      elsif allocated_to == 'anyone'
        Policies::NoPolicy
      elsif allocated_to == 'no_one'
        Policies::Unallocated
      else
        Policies::Allocated
      end
    end

    def audited_policy
      case self.audit_status
      when Audit::AUDITED
        Policies::Audited
      when Audit::NON_AUDITED
        Policies::NonAudited
      else
        Policies::NoPolicy
      end
    end
  end
end
