class Search
  class Executor
    def self.execute(query)
      scope = ContentItem.all

      query.filters.each do |filter|
        nested = Link.where(link_type: filter.link_type)

        if filter.by_source?
          nested = nested.where(source_content_id: filter.source_ids)
          nested = nested.select("target_content_id as content_id")
        else
          nested = nested.where(target_content_id: filter.target_ids)
          nested = nested.select("source_content_id as content_id")
        end

        scope = scope.where(content_id: nested)
      end

      Result.new(scope)
    end
  end
end
