module Audits
  class ContentQuery
    attr_reader :scope

    def self.filter_query(query)
      ContentQuery.new(query.clone.scope)
    end

    def initialize(content_scope = ContentItem.all)
      @scope = content_scope
    end

    def audit_status(audit_status)
      return self unless audit_status.present?

      case audit_status.to_sym
      when Audit::AUDITED
        audited
      when Audit::NON_AUDITED
        non_audited
      else
        self
      end
    end

    def audited
      @scope = @scope.joins(:audit)
      self
    end

    def non_audited
      @scope = @scope.where.not(content_id: Audit.all.select(:content_id))
      self
    end

    def passing
      @scope = @scope.where(content_id: Audit.passing.select(:content_id))
      self
    end

    def failing
      @scope = @scope.where(content_id: Audit.failing.select(:content_id))
      self
    end

    def content_items
      scope
    end

    def all_content_items
      scope.limit(nil).offset(nil)
    end
  end
end
