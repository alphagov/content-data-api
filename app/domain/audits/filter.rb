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
      :sort,
      :sort_direction,
      :theme_id,
      :title

    def audit_status
      @audit_status&.to_sym
    end

    def allocated_to
      @allocated_to&.to_s
    end

    def sort_by=(value)
      if value.present?
        raise "Invalid value: #{value}" unless value =~ /\A[a-z]+_(asc|desc)\z/

        values = value.split("_")
        @sort = values[0]
        @sort_direction = values[1]
      end
    end

    def sort_by
      "#{sort}_#{sort_direction}"
    end

    def allocated_policy
      if allocated_to == 'no_one'
        Policies::Unallocated
      elsif allocated_to == 'anyone'
        Policies::NoPolicy
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
