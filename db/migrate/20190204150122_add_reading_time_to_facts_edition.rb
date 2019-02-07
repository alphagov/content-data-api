class AddReadingTimeToFactsEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :facts_editions, :reading_time, :integer
  end
end
