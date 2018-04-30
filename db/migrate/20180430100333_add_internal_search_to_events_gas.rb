class AddInternalSearchToEventsGas < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :number_of_internal_searches, :integer, default: 0
  end
end
