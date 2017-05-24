class QuestionDecorator < Draper::Decorator
  delegate_all

  def css_class
    type_class = css_friendly(type)
    text_class = css_friendly(text)

    "question #{type_class} #{text_class}"
  end

  def css_id
    "question-#{id}"
  end

private

  def css_friendly(string)
    string
      .underscore
      .downcase
      .gsub(/[^a-z_\s]/, "")
      .split(/[_\s]+/)
      .join("-")
  end
end
