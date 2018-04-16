class Content::Parsers::Formats::TravelAdviceIndex
  def parse(json)
    html = []
    children = json.dig("links", "children")
    children.each do |child|
      html << child["country"]["name"]
    end
    html.join(" ")
  end

  def schemas
    ['travel_advice_index']
  end
end
