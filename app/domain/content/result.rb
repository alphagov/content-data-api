module Content
  class Result
    def initialize(scope)
      @scope = scope
    end

    def content_items
      @scope
    end

    def unpaginated
      @scope.limit(nil).offset(nil)
    end
  end
end
