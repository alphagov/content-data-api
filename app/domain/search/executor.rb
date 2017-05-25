class Search
  class Executor
    def self.execute(query)
      scope = ContentItem.all

      query.filters.each do |link_type, target_content_id|
        nested = Link
          .where(link_type: link_type, target_content_id: target_content_id)
          .select("source_content_id as content_id")

        scope = scope.where(content_id: nested)
      end

      Result.new(scope)
    end
  end
end
