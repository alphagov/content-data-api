class AddIsThisUsefulColumnsToEventsGas < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :is_this_useful_yes, :integer
    add_column :events_gas, :is_this_useful_no, :integer
  end
end
