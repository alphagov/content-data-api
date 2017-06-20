module ReportHelper
  def audited_count
    @search.dimension(:audited).content_items.total_count
  end

  def not_audited_count
    @search.dimension(:not_audited).content_items.total_count
  end

  def audited_percentage
    percentage(audited_count, out_of: @content_items.total_count)
  end

  def not_audited_percentage
    percentage(not_audited_count, out_of: @content_items.total_count)
  end

private

  def percentage(number, out_of:)
    return 0 if out_of.zero?
    number.to_f / out_of * 100
  end
end
