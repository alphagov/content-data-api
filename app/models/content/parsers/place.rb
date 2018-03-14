class Content::Parsers::Place
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
Content::Parser.register('place', Content::Parsers::Place.new)
