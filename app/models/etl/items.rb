require 'gds_api/rummager'

class ETL::Items
  def process
    raw_data = extract
    items = transform(raw_data)
    load(items)
  end

private

  def extract
    rummager.search_enum(
      {
        fields: 'content_id,title,link,description,organisations,indexable_content',
      },
      page_size: 1000,
      additional_headers: {},
    )
  end

  def transform(items)
    items = items.map do |item|
      {
        content_id: item['content_id'],
        title: item['title'],
        link: item['link'],
        description: item['description'],
        organisation_id: item.fetch('organisations', [{}]).first['content_id'],
        content: item['indexable_content'],
      }
    end

    items.map { |item| Dimensions::Item.find_or_initialize_by(item) }
  end

  def load(items)
    new_records = items.select(&:new_record?)
    Dimensions::Item.import(new_records, validate: false)
  end

  def rummager
    @rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
  end
end
