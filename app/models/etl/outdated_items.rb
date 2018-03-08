class ETL::OutdatedItems
  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    create_new_version_for_dirty_items
  end

private

  attr_reader :date

  def create_new_version_for_dirty_items
    Dimensions::Item.dirty_before(date).find_in_batches do |items|
      new_items = create_new_items(items)
      import_content_details(new_items)
    end
  end

  def create_new_items(items)
    new_items = items.map(&:new_version)
    ActiveRecord::Base.transaction do
      Dimensions::Item.import(new_items)
      Dimensions::Item.where(id: items.pluck('id')).update_all(dirty: false, latest: false)
    end
    new_items
  end

  def import_content_details(items)
    items.each do |item|
      ImportContentDetailsJob.perform_async(item.content_id, item.base_path)
    end
  end
end
