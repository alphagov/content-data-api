class Etl::Item::Content::Parsers::ServiceManualTopic
  def parse(json)
    html = []
    html << json.dig("description")
    groups = json.dig("details", "groups")
    unless groups.nil?
      groups.each do |group|
        html << group["name"]
        html << group["description"]
      end
    end
    html.join(" ")
  end

  def schemas
    %w[service_manual_topic]
  end
end
