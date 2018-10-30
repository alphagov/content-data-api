class AddWithdrawnAndHistoricalConstraints < ActiveRecord::Migration[5.2]
  def up
    Dimensions::Edition.where("withdrawn IS NULL").update_all(withdrawn: false)
    Dimensions::Edition.where("historical IS NULL").update_all(historical: false)
    change_column_null :dimensions_editions, :withdrawn, false
    change_column_null :dimensions_editions, :historical, false
  end

  def down
    change_column_null :dimensions_editions, :withdrawn, true
    change_column_null :dimensions_editions, :historical, true
  end
end
