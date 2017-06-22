class Search
  class Result
    attr_accessor :scope, :filter_options, :sort

    def initialize(scope, filter_options, sort)
      self.scope = scope
      self.filter_options = filter_options
      self.sort = sort
    end

    def content_items
      scope
    end

    def options_for(identifier)
      filter_options.fetch(identifier)
    end
  end
end
