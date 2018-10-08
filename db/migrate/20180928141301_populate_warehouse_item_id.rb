class PopulateWarehouseItemId < ActiveRecord::Migration[5.2]
	class Dimensions::Item < ActiveRecord::Base
	end

  def change
    multipart_types = %w[travel_advice guide]

    say 'populating warehouse_item_id from content_id:locale:base_path for guide, travel_advice'
    Dimensions::Item.where(document_type: multipart_types)
      .update_all(multipart_column_update)

    say 'populating warehouse_item_id from content_id:locale for single item types'
    Dimensions::Item.where.not(document_type: multipart_types)
      .update_all(single_item_column_update)

    say 'populating item id for the content with no locale'
    Dimensions::Item.where(warehouse_item_id: nil)
      .update_all(update_for_the_ones_with_no_locale)
  end

  def single_item_column_update
    Arel.sql("warehouse_item_id = content_id ||':' || locale")
  end

  def multipart_column_update
    Arel.sql("warehouse_item_id = content_id ||':' || locale || ':' || base_path")
  end

  def update_for_the_ones_with_no_locale
    Arel.sql("warehouse_item_id = content_id || ':en'")
  end
end
