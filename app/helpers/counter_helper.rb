module CounterHelper
  def first_item_index
    (@content_items.current_page - 1) * @content_items.limit_value + 1
  end

  def last_item_index
    [first_item_index + @content_items.limit_value - 1, @content_items.total_count].min
  end
end
