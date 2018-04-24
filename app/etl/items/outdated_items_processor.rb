class Items::OutdatedItemsProcessor
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time(process: :outdated_items) do
      populate_outdated_items
    end
  end

private

  attr_reader :date

  def populate_outdated_items
    Dimensions::Item.outdated_before(date).find_in_batches.with_index do |items, index|
      log process: :outdated_items, message: "processing #{items.length} items in batch: #{index}"
      import_content_details(items)
    end
  end

  def import_content_details(items)
    log process: :import_content_details, message: "creating #{items.length} ImportContentDetailsJobs"
    items.each do |item|
      Items::Jobs::ImportContentDetailsJob.perform_async(item.id)
    end
  end
end
