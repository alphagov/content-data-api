class Parsers::PlaceParser
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
Parsers::ContentExtractors.register('place', Parsers::PlaceParser.new)
