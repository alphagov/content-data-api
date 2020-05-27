class Etl::Edition::Content::Parsers::ServiceManualServiceToolkit
  def parse(json)
    html = []
    items = json.dig("details", "collections")
    unless items.nil?
      items.each do |item|
        html << item["title"]
        html << item["description"]
        links = item.dig("links")
        next if links.nil?

        links.each do |link|
          html << link["title"]
          html << link["description"]
        end
      end
      html.join(" ")
    end
  end

  def schemas
    %w[service_manual_service_toolkit]
  end
end
