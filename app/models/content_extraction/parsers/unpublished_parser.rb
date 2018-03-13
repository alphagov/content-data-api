class ContentExtraction::Parsers::UnpublishedParser
  def parse(json)
    json.dig("details", "explanation")
  end
end
ContentExtraction::ContentParser.register('unpublished',
  ContentExtraction::Parsers::UnpublishedParser.new)
