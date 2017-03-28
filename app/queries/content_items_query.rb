class ContentItemsQuery
  def self.build(options)
    ContentItemsQuery.new.results(options)
  end

  def results(options = {})
    relation = ContentItem.all
    relation = filter_by_taxonomy(relation, options[:taxonomy])
    relation = filter_by_organisations(relation, options[:organisation])
    relation = filter_by_title(relation, options[:query])
    relation
      .order("#{options[:sort]} #{options[:order]}")
      .page(options[:page])
  end

private

  def filter_by_taxonomy(relation, taxonomy)
    return relation unless taxonomy
    relation.joins(:taxonomies).where('taxonomies.id = ?', taxonomy.id)
  end

  def filter_by_organisations(relation, organisation)
    return relation unless organisation
    relation.joins(:organisations).where('organisations.id = ?', organisation.id)
  end

  def filter_by_title(relation, query)
    return relation unless query
    relation.where('content_items.title ilike ?', "%#{query}%")
  end
end
