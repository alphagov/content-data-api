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
      :theme_id

    def audit_status=(value)
      @audit_status = if value.blank?
                        nil
                      else
                        value.to_sym
                      end
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
      if allocated_to == 'no_one'
        Policies::Unallocated
      elsif allocated_to.blank?
        Policies::NoPolicy
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
        Policies::NoPolicy
      end
    end
  end
end
