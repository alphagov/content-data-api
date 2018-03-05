class ETL::Dirty
  def self.process(*args)
    new(*args).process
  end

  def process
    create_new_version_for_dirty_items
  end

private

  def create_new_version_for_dirty_items
    Dimensions::Item.dirty.each do |item|
      new_item = item.new_version!
      ImportContentDetailsJob.perform_async(new_item.content_id, new_item.base_path)
    end
  end
end
