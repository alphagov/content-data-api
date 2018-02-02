class ETL::Items
  def self.process(*args)
    new(*args).process
  end

  attr_reader :content_items_service

  def process
    raw_data = extract
    items = transform(raw_data)
    load(items)
  end

private

  def extract
    Content::ItemsService.new.fetch_all_with_id_and_path
  end

  def transform(raw_data)
    raw_data.map do |item|
      {
        content_id: item[:content_id],
        path: item[:base_path],
        latest: true,
      }
    end
  end

  def load(items)
    Dimensions::Item.import(items, batch_size: 5000)
  end
end
