module FormatHelper
  def format_number(n)
    number_with_delimiter(n, delimiter: ",")
  end

  def format_datetime(d)
    return "Never" unless d

    date = d.to_date.to_s(:short)
    time_ago = time_ago_in_words(d)

    "#{date} (#{time_ago} ago)"
  end

  def format_boolean(b)
    b ? "Yes" : "No"
  end

  def format_array(arr)
    arr.any? ? arr.join(", ") : "None"
  end
end
