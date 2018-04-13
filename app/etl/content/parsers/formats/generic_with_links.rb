class Content::Parsers::Formats::GenericWithLinks
  def parse(json)
    html = []
    links = json.dig("details", "external_related_links")
    links.each do |link|
      html << link["title"]
    end
    html.join(" ")
  end

  def schemas
    ['generic_with_external_related_links']
  end
end
