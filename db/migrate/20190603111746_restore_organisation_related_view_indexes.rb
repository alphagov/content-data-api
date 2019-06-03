class RestoreOrganisationRelatedViewIndexes < ActiveRecord::Migration[5.2]
  PERIODS = %w[
    last_thirty_days
    last_months
    last_three_months
    last_six_months
    last_twelve_months
  ].freeze

  def up
    fields = %i[primary_organisation_id upviews warehouse_item_id]

    PERIODS.each do |period|
      add_index(
        "aggregations_search_#{period}".to_sym,
        fields,
        name: "search_#{period}_organisation_id".to_sym
      )
    end
  end

  def down
    PERIODS.each do |period|
      remove_index(
        "aggregations_search_#{period}".to_sym,
        name: "search_#{period}_organisation_id".to_sym
      )
    end
  end
end
