class ProcessNameIsNotNull < ActiveRecord::Migration[5.1]
  def up
    Events::GA.update_all(process_name: 1)
    change_column :events_gas, :process_name, :integer, null: false
  end

  def down
    change_column :events_gas, :process_name, :integer, null: true
    Events::GA.update_all(process_name: nil)
  end
end
