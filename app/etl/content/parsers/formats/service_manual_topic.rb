class Content::Parsers::Formats::ServiceManualTopic
  def parse(json)
    html = []
    html << json.dig("description")
    json.dig("details", "groups").each do |group|
      html << group["name"]
      html << group["description"]
    end
    html.join(" ")
  end

  def schemas
    ['service_manual_topic']
  end
end
