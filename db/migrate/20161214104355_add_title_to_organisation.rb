class AddTitleToOrganisation < ActiveRecord::Migration[5.0]
  def change
    add_column :organisations, :title, :string
  end
end
