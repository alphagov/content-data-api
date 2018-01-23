module FormatHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper

  def format_number(n)
    number_with_delimiter(n, delimiter: ",")
  end

  def format_datetime(d, relative: true)
    return "Never" unless d

    date = d.to_date.to_s(:short)
    time_ago = time_ago_in_words(d)

    relative ? "#{date} (#{time_ago} ago)" : date
  end

  def format_boolean(b)
    b ? "Yes" : "No"
  end

  def format_array(arr)
    arr.any? ? arr.join(", ") : "None"
  end
end
