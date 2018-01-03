require 'gds_api/rummager'

class ETL::Items
  def self.process(*args)
    new(*args).process
  end

  def process
    raw_data = extract
    items = transform(raw_data)
    load(items)
  end

private

  def extract
    rummager.search_enum(
      {
        fields: 'content_id,title,link,description,organisations',
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
      }
    end

    items.map { |item| Dimensions::Item.find_or_initialize_by(item) }
  end

  def load(items)
    new_records = items.select(&:new_record?)
    result = Dimensions::Item.import(new_records, validate: false)

    existing_records = items - new_records
    all_ids = result.ids + existing_records.pluck(:id)

    Dimensions::Item.where(id: all_ids)
  end

  def rummager
    @rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
  end
end
