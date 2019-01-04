namespace :temp do
  desc "Update withdrawn editions"
  task repopulate_pdf_count: :environment do
    Dimensions::Edition.latest.relevant_content.includes(:publishing_api_event).in_batches do |group|
      group.each do |edition|
        if edition.publishing_api_event
          pdf_count = Etl::Edition::Metadata::NumberOfPdfs.parse(edition.publishing_api_event.payload)
          edition.facts_edition.update!(pdf_count: pdf_count)
        end
      end
      putc '.'
    end
    puts '\nDone!\n'
  end
end
