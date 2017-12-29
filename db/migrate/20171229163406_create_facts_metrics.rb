class CreateFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :facts_metrics do |t|
      t.date :dimensions_date_id, index: true
      t.references :dimensions_item, foreign_key: true
      t.references :dimensions_organisation, foreign_key: true

      t.timestamps
    end

    add_foreign_key :facts_metrics, :dimensions_dates, foreign_key: :dimensions_date_id, primary_key: :date
  end
end
