class CreateEventsFeedexes < ActiveRecord::Migration[5.1]
  def change
    create_table :events_feedexes do |t|
      t.date :date
      t.string :page_path
      t.integer :number_of_issues
    end
  end
end
