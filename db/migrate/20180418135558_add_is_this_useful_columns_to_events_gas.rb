class AddIsThisUsefulColumnsToEventsGas < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :is_this_useful_yes, :integer, default: 0
    add_column :events_gas, :is_this_useful_no, :integer, default: 0
  end
end
