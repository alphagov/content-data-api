class AddProcessNameToGaEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :process_name, :integer
  end
end
