class DropTaxons < ActiveRecord::Migration[5.1]
  def change
    drop_table :taxons do |t|
      t.string :content_id
      t.string :title

      t.timestamps
    end
  end
end
