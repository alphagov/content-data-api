class AddNotNullConstraintLocale < ActiveRecord::Migration[5.2]
  def change
    change_column_null :dimensions_editions, :locale, false
  end
end
