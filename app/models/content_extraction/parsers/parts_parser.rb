class ContentExtraction::Parsers::PartsParser
  def parse(json)
    html = []
    json.dig("details", "parts").each do |part|
      html << part["title"]
      html << part["body"]
    end
    html.join(" ")
  end
end
%w[guide travel_advise].each do |schema|
  ContentExtraction::ContentParser.register(schema, ContentExtraction::Parsers::PartsParser.new)
end
