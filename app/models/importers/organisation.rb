class Importers::Organisation
  attr_reader :slug, :batch, :start
  attr_writer :start

  def initialize(slug, batch: 10, start: 0)
    @slug = slug
    @batch = batch
    @start = start
  end

  def run
    organisation = ::Organisation.create!(slug: slug)
    loop do
      result = search_content_items_for_organisation
      result.each do |content_item_attributes|
        attributes = content_item_attributes.slice('content_id')
        organisation.content_items << ContentItem.new(attributes)
      end

      break if last_page?(result)

      next_page!
    end
    raise 'No result for slug' if organisation.content_items.empty?
  end

private

  def last_page?(results)
    results.length < batch
  end

  def next_page!
    self.start += batch
  end

  def search_content_items_for_organisation
    response = HTTParty.get(search_api_end_point)
    JSON.parse(response.body).fetch('results')
  end

  def search_api_end_point
    "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=content_id&start=#{start}"
  end
end
