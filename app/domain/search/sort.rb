class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "content_items.six_months_page_views desc"),
      ]
    end

    attr_reader :identifier

    def initialize(identifier, sort_query)
      @identifier = identifier
      @sort_query = sort_query
    end

    def apply(scope)
      # Sorting by id guarrentees a deterministic order in the case
      # where the other sort criteria don't differ between the items
      # being sorted. This is critical to ensure that the user
      # experience is consistent in terms of the order items are
      # displayed, and that features provided by PostgreSQL like ORDER
      # and OFFSET work.
      scope.order("#{sort_query}, content_items.id")
    end

  private

    attr_accessor :sort_query
  end
end
