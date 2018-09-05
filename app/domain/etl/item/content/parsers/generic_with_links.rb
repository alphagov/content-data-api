class Etl::Item::Content::Parsers::GenericWithLinks
  def parse(json)
    html = []
    links = json.dig("details", "external_related_links")
    unless links.nil?
      links.each do |link|
        html << link["title"]
      end
      html.join(" ")
    end
  end

  def schemas
    %w[generic_with_external_related_links]
  end
end
