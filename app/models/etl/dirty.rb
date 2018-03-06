class ETL::Dirty
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
    Dimensions::Item.dirty_before(date).each do |item|
      new_item = item.new_version!
      ImportContentDetailsJob.perform_async(new_item.content_id, new_item.base_path)
    end
  end
end
