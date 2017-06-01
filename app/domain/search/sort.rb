class Search
  class Sort
    def self.find_by(identifier)
      sort = SORTS.detect { |s| s.identifier == identifier }
      raise ::SortError, "unrecognised sort" unless sort
      sort
    end

    attr_reader :identifier

    def initialize(identifier, sort_query)
      @identifier = identifier
      @sort_query = sort_query
    end

    def apply(scope)
      scope.order(sort_query)
    end

    SORTS = [
      Sort.new(:page_views_desc, "six_months_page_views desc")
    ].freeze

  private

    attr_accessor :sort_query
    attr_writer :identifier
  end

  class ::SortError < StandardError;
  end
end
