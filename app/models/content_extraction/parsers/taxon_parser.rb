class ContentExtraction::Parsers::TaxonParser
  def parse(json)
    html = []
    html << json.dig("description")
    return unless json.dig("links").include?("child_taxons")
    children = json.dig("links", "child_taxons")
    children.each do |child|
      html << child["title"]
      html << child["description"]
    end
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('taxon',
  ContentExtraction::Parsers::TaxonParser.new)
