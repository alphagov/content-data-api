class DropReportRows < ActiveRecord::Migration[5.1]
  def change
    drop_table :report_rows do |t|
      t.string "content_id"
      t.json "data"
      t.timestamps null: false
    end
  end
end
