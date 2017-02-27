class ContentItemsQuery
  def self.build(options)
    ContentItemsQuery.new.results(options)
  end

  def results(options = {})
    relation = if options[:organisation]
                 options[:organisation].content_items
               else
                 ContentItem.all
               end

    relation
      .order("#{options[:sort]} #{options[:order]}")
      .page(options[:page])
  end
end
