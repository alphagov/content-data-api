class Etl::Edition::Content::Parsers::ServiceManualHomepage
  def parse(json)
    html = []
    html << json["title"]
    html << json["description"]

    children = json.dig("links", "children")
    if children.present?
      children.each do |child|
        html << child["title"]
        html << child["description"]
      end
    end

    html.compact.join(" ")
  end

  def schemas
    %w[service_manual_homepage]
  end
end
