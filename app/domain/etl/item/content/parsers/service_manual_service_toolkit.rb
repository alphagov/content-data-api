class Etl::Item::Content::Parsers::ServiceManualServiceToolkit
  def parse(json)
    html = []
    items = json.dig('details', 'collections')
    unless items.nil?
      items.each do |item|
        html << item['title']
        html << item['description']
        links = item.dig('links')
        unless links.nil?
          links.each do |link|
            html << link['title']
            html << link['description']
          end
        end
      end
      html.join(' ')
    end
  end

  def schemas
    ['service_manual_service_toolkit']
  end
end
