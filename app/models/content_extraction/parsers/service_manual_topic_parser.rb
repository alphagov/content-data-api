class ContentExtraction::Parsers::ServiceManualTopicParser
  def parse(json)
    html = []
    html << json.dig("description")
    json.dig("details", "groups").each do |group|
      html << group["name"]
      html << group["description"]
    end
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register 'service_manual_topic', ContentExtraction::Parsers::ServiceManualTopicParser.new
