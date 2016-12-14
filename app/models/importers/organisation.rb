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
        content_item_organisations = content_item_attributes['organisations']
        if content_item_organisations.present?
          organisation.update!(title: content_item_organisations.first['title'])
        end

        content_id = content_item_attributes['content_id']
        link = content_item_attributes['link']

        if content_id.present?
          content_store_item = content_item_store(link)
          attributes = content_item_attributes.slice(*CONTENT_ITEM_FIELDS)
            .merge(content_store_item.slice(*CONTENT_STORE_FIELDS))
          organisation.content_items << ContentItem.new(attributes)
        else
          log("There is not content_id for #{slug}")
        end
      end

      break if last_page?(result)

      next_page!
    end
    raise 'No result for slug' if organisation.content_items.empty?
  end

private

  CONTENT_ITEM_FIELDS = %w(content_id link title).freeze
  CONTENT_STORE_FIELDS = %w(public_updated_at document_type).freeze
  SEARCH_API_FIELDS = CONTENT_ITEM_FIELDS + %w(organisations)

  private_constant :CONTENT_ITEM_FIELDS, :SEARCH_API_FIELDS

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
    "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=#{SEARCH_API_FIELDS.join(',')}&start=#{start}"
  end

  def content_item_store(base_path)
    endpoint = content_item_end_point(base_path)
    response = HTTParty.get(endpoint)
    JSON.parse(response.body)
  end

  def content_item_end_point(base_path)
    "https://www.gov.uk/api/content#{base_path}"
  end

  def log(message)
    unless Rails.env.test?
      Logger.new(STDOUT).warn(message)
    end
  end
end
