require 'gds_api/rummager'

class ETL::Items
  def self.process(*args)
    new(*args).process
  end

  attr_reader :new_items

  def process
    ActiveRecord::Base.transaction do
      raw_data = extract
      items = transform(raw_data)
      load(items)
    end
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

  def transform(raw_data)
    raw_data.map do |item|
      {
        content_id: item['content_id'],
        title: item['title'],
        link: item['link'],
        description: item['description'],
        organisation_id: item.fetch('organisations', [{}]).first['content_id'],
      }
    end
  end

  def load(items)
    load_setup(items)

    find_new_items
    update_latest_flag
    import_new_items

    load_cleanup

    return_latest_items
  end

  def rummager
    @rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
  end

  def load_setup(items)
    TemporaryItemStore.import(items, batch_size: 5000)
  end

  def find_new_items
    result = ActiveRecord::Base.connection.execute(new_items_sql)
    @new_items = result.map do |row|
      item = Dimensions::Item.new(row)
      item.latest = true
      item
    end
  end

  def update_latest_flag
    new_items_ids = new_items.pluck(:content_id)
    Dimensions::Item.where('content_id IN (?)', new_items_ids).update_all(latest: false)
  end

  def import_new_items
    Dimensions::Item.import(new_items, batch_size: 5000)
  end

  def return_latest_items
    Dimensions::Item.where(latest: true)
  end

  def load_cleanup
    TemporaryItemStore.delete_all
  end

  def new_items_sql
    <<~SQL
      SELECT content_id, title, link, description, organisation_id
      FROM dimensions_items_temps
       EXCEPT
      SELECT content_id, title, link, description, organisation_id
      FROM dimensions_items
    SQL
  end

  class TemporaryItemStore < ApplicationRecord
    self.table_name = 'dimensions_items_temps'
  end
end
