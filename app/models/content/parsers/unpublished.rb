class Content::Parsers::Unpublished
  def parse(json)
    json.dig("details", "explanation")
  end

  def schemas
    ['unpublished']
  end
end
