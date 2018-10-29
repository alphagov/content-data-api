class RemoveDuplicatedBasePathsMetrics < ActiveRecord::Migration[5.2]
  def up
    loop do
      say "------> Deleting batch of duplications"
      total = clean_up_duplicated_metrics!
      break if total.zero?
    end
  end

private

  def clean_up_duplicated_metrics!
    edition_ids = Dimensions::Edition.
      select('base_path, count(id), max(id) as id').
      where(latest: true).
      group(:base_path).
      having('count(id) > 1').
      map(&:id)

    total = edition_ids.count
    edition_ids.each_with_index do |edition_id, index|
      say "#{index + 1} / #{total} : Deleting metrics for Edition: #{edition_id}"
      Facts::Metric.where(dimensions_edition_id: edition_id).delete_all
      Dimensions::Edition.find(edition_id).facts_edition.destroy
      Dimensions::Edition.find(edition_id).destroy
    end

    total
  end
end
