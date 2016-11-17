class ContentItem < ApplicationRecord
  belongs_to :organisation

  def self.import
    Organisation.all.each do |organisation|
      batch = 10 #TODO Decide the right batch amount
      url = "https://www.gov.uk/api/search.json?start=0&filter_organisations=#{organisation.slug}&fields=content_id&count=#{batch}"
      response_body = RestClient.get(url).body
      JSON.parse(response_body)["results"].inject([]) do |items, item|
        content = item.slice("content_id")
        items << self.create(content.merge(organisation: organisation))
        items
      end
      
      Organisation.update(
        organisation.id,
        number_of_pages: organisation.content_items.count
      )
    end
  end
end
