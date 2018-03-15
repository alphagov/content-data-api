class ETL::OutdatedItems
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time(process: :outdated_items) do
      create_new_version_for_outdated_items
    end
  end

private

  attr_reader :date

  def create_new_version_for_outdated_items
    Dimensions::Item.outdated_before(date).find_in_batches.with_index do |items, index|
      log message: "processing #{items.length} outdated items in batch: #{index}"
      new_items = create_new_items(items)
      import_content_details(new_items)
    end
  end

  def create_new_items(items)
    new_items = items.map(&:new_version)
    ActiveRecord::Base.transaction do
      Dimensions::Item.import(new_items)
      Dimensions::Item.where(id: items.pluck('id')).update_all(outdated: false, latest: false)
    end
    new_items
  end

  def import_content_details(items)
    items.each do |item|
      ImportContentDetailsJob.perform_async(item.content_id, item.base_path)
    end
  end
end
