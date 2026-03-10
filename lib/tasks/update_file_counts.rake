namespace :editions do
  desc "Update file counts for editions"
  task update_file_counts: :environment do
    editions = Dimensions::Edition.all.live.includes(:facts_edition, :publishing_api_event)
    edition_count = editions.count
    batch_size = 100
    total_batches = (edition_count.to_f / batch_size).ceil

    puts "Updating #{edition_count} editions"

    ActiveRecord::Base.transaction do
      editions.in_batches(of: batch_size).each_with_index do |batch, batch_index|
        payload = batch.map do |edition|
          file_counter = Etl::Edition::Metadata::FileCounter.new(edition.publishing_api_event.payload)

          edition.facts_edition.attributes.merge(
            "pdf_count" => file_counter.pdf_count,
            "doc_count" => file_counter.doc_count,
          )
        end

        Facts::Edition.upsert_all(payload)

        puts "Updated batch #{batch_index + 1} of #{total_batches}"
      end
    end

    puts "Refreshing search aggregations"
    Etl::Aggregations::Search.process
    puts "Finished refreshing search aggregations"
  end
end
