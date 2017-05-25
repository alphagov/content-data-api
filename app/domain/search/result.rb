class Search
  class Result
    attr_accessor :scope

    def initialize(scope)
      self.scope = scope
    end

    def content_items
      scope
    end
  end
end
