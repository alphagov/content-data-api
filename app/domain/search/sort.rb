class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(
          :page_views_desc,
          "content_items.six_months_page_views desc, content_items.base_path asc",
          "(content_items.six_months_page_views = ? AND content_items.base_path > ?) OR content_items.six_months_page_views < ?"
        ),
      ]
    end

    attr_reader :identifier

    def initialize(identifier, sort_query, next_item_criteria)
      @identifier = identifier
      # Break ties on base path for a stable sort order
      @sort_query = sort_query
      @next_item_criteria = next_item_criteria
    end

    def apply(scope)
      scope.order(@sort_query)
    end

    def apply_next_item(scope, previous_content_item)
      scope
        .where(
          @next_item_criteria,
          previous_content_item[:six_months_page_views],
          previous_content_item[:base_path],
          previous_content_item[:six_months_page_views],
        )
    end
  end
end
