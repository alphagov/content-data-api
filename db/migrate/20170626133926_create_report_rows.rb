class CreateReportRows < ActiveRecord::Migration[5.1]
  def change
    create_table :report_rows do |t|
      t.string :content_id
      t.json :data
    end

    add_index :report_rows, :content_id, unique: true
  end
end
