module Audits
  Filter = Struct.new(
    :after,
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
    :title,
    :topics
  ) do

    def initialize(hash = {})
      hash.each do |key, value|
        self[key] = value
      end

      self[:organisations] = [] if self[:organisations].blank?
      self[:topics] = [] if self[:topics].blank?
    end

    def audit_status
      self[:audit_status]&.to_sym
    end

    def allocated_to
      self[:allocated_to]&.to_s
    end

    def page
      self[:page]&.to_i
    end

    def per_page
      self[:per_page]&.to_i
    end

    def sort_by
      Sort.combine(sort, sort_direction)
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
      case audit_status
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
