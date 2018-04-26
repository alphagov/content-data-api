class Item::Content::Parsers::Parts
  def parse(json)
    html = []
    parts = json.dig("details", "parts")
    return if parts.nil?
    parts.each do |part|
      html << part["title"]
      html << part["body"]
    end
    html.join(" ")
  end

  def schemas
    %w[guide travel_advice]
  end
end
