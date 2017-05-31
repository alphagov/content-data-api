class Search
  class AuditFilter
    AUDIT_STATUSES_IDENTIFIERS = [
      :audited,
      :non_audited,
    ].freeze

    attr_accessor :status


    def initialize(status)
      self.status = status.to_sym

      raise_if_unrecognised_audit_status
    end

    def apply(scope)
      if self.status == :audited
        scope.joins(:audit)
      elsif self.status == :non_audited
        scope.left_outer_joins(:audit).where("content_items.content_id not IN( select content_id from audits)")
      else
        scope
      end
    end

    def raise_if_unrecognised_audit_status
      if status && !AUDIT_STATUSES_IDENTIFIERS.include?(status)
        raise AuditStatusError, "unrecognised audit status: #{status}"
      end
    end

    def self.all_status
      [
        OpenStruct.new(id: 'audited', name: "Audited"),
        OpenStruct.new(id: 'non_audited', name: "Non Audited"),
      ]
    end
  end

  class ::AuditStatusError < StandardError; end
end
