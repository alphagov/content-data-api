class Etl::Item::Content::Parsers::TravelAdviceIndex
  def parse(json)
    html = []
    children = json.dig("links", "children")
    return if children.nil?
    children.each do |child|
      country = child.dig("country", "name")
      html << country unless country.nil?
    end
    html.join(" ")
  end

  def schemas
    %w[travel_advice_index]
  end
end
