class Content::Parsers::ServiceManualTopic
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
Content::Parser.register 'service_manual_topic', Content::Parsers::ServiceManualTopic.new
