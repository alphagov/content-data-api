class Content::Parsers::Formats::Parts
  def parse(json)
    html = []
    json.dig("details", "parts").each do |part|
      html << part["title"]
      html << part["body"]
    end
    html.join(" ")
  end

  def schemas
    %w[guide travel_advice]
  end
end
