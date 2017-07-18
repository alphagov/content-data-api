class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "content_items.six_months_page_views desc"),
        Sort.new(:title_desc, "content_items.title desc"),
        Sort.new(:title_asc, "content_items.title asc"),
      ]
    end

    attr_reader :identifier

    def initialize(identifier, sort_query)
      @identifier = identifier
      @sort_query = sort_query
    end

    def apply(scope)
      scope.order(sort_query)
    end

  private

    attr_accessor :sort_query
  end
end
