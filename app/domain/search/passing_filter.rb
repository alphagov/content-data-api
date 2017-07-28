class Search
  class PassingFilter
    attr_accessor :passing

    def initialize(passing)
      self.passing = passing
    end

    def apply(scope)
      nested = passing ? Audits::Audit.passing : Audits::Audit.failing
      scope.where(content_id: nested.select(:content_id))
    end
  end
end
