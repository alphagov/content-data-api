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

    def next_content_item(content_item)
      next_scope =
        sort.where_only_after(
          content_items.unscope(:limit, :offset),
          content_item
        )

      limit = 10

      loop do
        ids = next_scope.limit(limit).pluck(:id)
        current_item_index = ids.index(content_item.id)

        if current_item_index.nil?
          limit *= 2
          # Give up if the limit is greater than 500, as this process
          # is probably taking too long, and might not even finish if
          # somehow the content item provided has fallen out of the
          # filter criteria
          return false if limit > 500
          next
        elsif limit == (current_item_index + 1)
          limit += 1
          next
        else
          return next_scope.find_by(id: ids[current_item_index + 1])
        end
      end
    end
  end
end
