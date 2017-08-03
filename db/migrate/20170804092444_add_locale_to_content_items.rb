class AddLocaleToContentItems < ActiveRecord::Migration[5.1]
  def up
    add_column :content_items, :locale, :string
    ActiveRecord::Base.connection.execute("UPDATE content_items SET locale = 'en'")
    change_column_null :content_items, :locale, false
  end

  def down
    remove_column :content_items, :locale
  end
end
