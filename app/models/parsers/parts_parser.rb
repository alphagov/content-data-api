class Parsers::PartsParser
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
  Parsers::ContentExtractors.register(schema, Parsers::PartsParser.new)
end
