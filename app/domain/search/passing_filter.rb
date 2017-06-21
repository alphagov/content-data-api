class Search
  class PassingFilter
    attr_reader :identifier, :name

    def initialize(passing)
      @passing = passing
    end

    def apply(scope)
      things = Response.joins(:question).where(
        "responses.audit_id = audits.id AND questions.type = 'BooleanQuestion' AND responses.value = 'no'"
      )

      scope.joins(:audit).where(
        @passing ? things.exists.not : things.exists
      )
    end
  end
end
