namespace :warehouse_item_id do
  desc 'Populate the warehouse_item_id column'
  task populate: :environment do
    multipart_types = %w[travel_advice guide]

    Dimensions::Item.where(document_type: multipart_types)
      .update_all(multipart_column_update)

    Dimensions::Item.where.not(document_type: multipart_types)
      .update_all(single_item_column_update)
  end

  def single_item_column_update
    Arel.sql("warehouse_item_id = content_id ||':' || locale")
  end

  def multipart_column_update
    Arel.sql("warehouse_item_id = content_id ||':' || locale || ':' || base_path")
  end
end
