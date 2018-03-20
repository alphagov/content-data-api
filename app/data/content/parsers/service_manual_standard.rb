class Content::Parsers::ServiceManualStandard
  def parse(json)
    html = []
    html << json.dig('title')
    html << json.dig('details', 'body')
    json.dig('links', 'children').each do |child|
      html << child['title']
      html << child['description']
    end
    html.join(" ")
  end

  def schemas
    ['service_manual_service_standard']
  end
end
