class Items::PreloadItemsProcessor
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def process
    time(process: :items) do
      raw_data = extract
      items = transform(raw_data)
      load(items)
    end
  end

private

  def extract
    Items::Clients::PublishingAPI.new.fetch_all(%w[content_id base_path locale])
  end

  def transform(raw_data)
    raw_data.map do |item|
      {
        content_id: item[:content_id],
        base_path: item[:base_path],
        locale: item[:locale],
        publishing_api_payload_version: 0,
        latest: true,
      }
    end
  end

  def load(items)
    result = Dimensions::Item.import(items, batch_size: 5000)
    create_import_detail_job(result.ids)
  end

  def create_import_detail_job(_item_ids)
    Dimensions::Item.find_each do |item|
      Items::Jobs::ImportContentDetailsJob.perform_async(item.id)
    end
  end
end
