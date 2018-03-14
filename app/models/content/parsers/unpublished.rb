class Content::Parsers::Unpublished
  def parse(json)
    json.dig("details", "explanation")
  end
end
Content::Parser.register('unpublished',
  Content::Parsers::Unpublished.new)
