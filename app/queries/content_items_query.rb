class ContentItemsQuery
  def self.build(options)
    ContentItemsQuery.new.results(options)
  end

  def results(options = {})
    relation = if options[:organisation].present? && options[:taxonomy].present?
                 options[:organisation].content_items.merge(options[:taxonomy].content_items)
               elsif options[:organisation].present?
                 options[:organisation].content_items
               elsif options[:taxonomy].present?
                 options[:taxonomy].content_items
               else
                 ContentItem.all
               end
    relation = relation.where('title ilike ?', "%#{options[:query]}%") if options[:query].present?
    relation
      .order("#{options[:sort]} #{options[:order]}")
      .page(options[:page])
  end
end
