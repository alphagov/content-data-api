class Search
  def initialize
    self.query = Query.new
  end

  def filter_by(link_type:, source_ids: nil, target_ids: nil)
    filter = LinkFilter.new(
      link_type: link_type,
      source_ids: source_ids,
      target_ids: target_ids,
    )

    query.filter_by(filter)
  end

  def execute
    self.result = Executor.execute(query)
    nil
  end

  def content_items
    result.content_items
  end

  def per_page=(value)
    query.per_page = value
  end

  def per_page
    query.per_page
  end

  def page
    query.page
  end

  def page=(value)
    query.page = value
  end

  def sort=(identifier)
    query.sort = identifier
    raise_if_unrecognised_sort
  end

  def sort
    query.sort
  end

private

  attr_accessor :query, :result


  SORT_IDENTIFIERS = [
    :page_views_desc,
  ].freeze

  def raise_if_unrecognised_sort
    raise ::SortError, "unrecognised sort" unless SORT_IDENTIFIERS.include?(sort)
  end

  class ::SortError < StandardError
  end
end
