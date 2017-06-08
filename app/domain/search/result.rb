class Search
  class Result
    attr_accessor :scope, :filter_options

    def initialize(scope, filter_options)
      self.scope = scope
      self.filter_options = filter_options
    end

    def content_items
      scope
    end

    def options_for(link_type)
      filter_options.fetch(link_type)
    end
  end
end
