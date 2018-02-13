class CreateEventsGas < ActiveRecord::Migration[5.1]
  def change
    create_table :events_gas do |t|
      t.date :date
      t.string :page_path
      t.integer :pageviews
      t.integer :unique_pageviews

      t.timestamps
      t.index %w[page_path date]
    end
  end
end
