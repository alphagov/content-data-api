class Search
  class AuditFilter
    extend Findable

    def self.all
      [
        AuditFilter.new(:audited, "Audited"),
        AuditFilter.new(:non_audited, "Non Audited"),
      ]
    end

    attr_reader :identifier, :name

    def initialize(identifier, name)
      @identifier = identifier.to_sym
      @name = name
    end

    def apply(scope)
      if self.identifier == :audited
        scope.joins(:audit)
      elsif self.identifier == :non_audited
        scope.where.not(content_id: Audit.all.select(:content_id))
      else
        scope
      end
    end

    def raise_if_unrecognised_audit_status
      if status && !AUDIT_STATUSES_IDENTIFIERS.include?(status)
        raise AuditStatusError, "unrecognised audit status: #{status}"
      end
    end

  private

    attr_writer :identifier
  end
end
