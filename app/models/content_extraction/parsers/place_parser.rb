class ContentExtraction::Parsers::PlaceParser
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('place', ContentExtraction::Parsers::PlaceParser.new)
