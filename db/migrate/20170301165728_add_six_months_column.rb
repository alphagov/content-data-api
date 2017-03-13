class AddSixMonthsColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :six_months_page_views, :integer, default: 0
  end
end
