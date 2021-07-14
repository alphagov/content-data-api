class Etl::Edition::Content::Parsers::ServiceManualStandard
  def parse(json)
    html = []
    html << json["title"]
    html << json.dig("details", "body")
    children = json.dig("links", "children")
    unless children.nil?
      children.each do |child|
        html << child["title"]
        html << child["description"]
      end
    end
    html.join(" ")
  end

  def schemas
    %w[service_manual_service_standard]
  end
end
