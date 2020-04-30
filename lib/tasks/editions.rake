namespace :editions do
  desc "Update withdrawn editions"
  task set_withdrawn: :environment do
    editions = Dimensions::Edition.all
    puts "Updating #{editions.count} editions"

    ActiveRecord::Base.transaction do
      Dimensions::Edition.find_each(batch_size: 1000).each_with_index do |edition, index|
        payload = edition.publishing_api_event.payload
        edition.withdrawn = Streams::Messages::BaseMessage.new(payload, nil).withdrawn_notice?
        edition.save!
        puts "Updated editions #{index}" if (index % 5000).zero?
      end
    end

    puts "Done!"
  end

  desc "Update organisation ids for editions"
  task set_organisation_ids: :environment do
    editions = Dimensions::Edition.all
    puts "Updating #{editions.count} editions"

    ActiveRecord::Base.transaction do
      Dimensions::Edition.find_each(batch_size: 1000).each_with_index do |edition, index|
        payload = edition.publishing_api_event.payload
        edition.organisation_ids = Streams::Messages::BaseMessage.new(payload, nil).organisation_ids
        edition.save!
        puts "Updated editions #{index}" if (index % 5000).zero?
      end
    end

    puts "Done!"
  end

  desc "Update existing live editions"
  task update_existing: :environment do
    editions = Dimensions::Edition.all.live
    puts "Updating #{editions.count} editions"

    ActiveRecord::Base.transaction do
      editions.find_each(batch_size: 1000).each_with_index do |edition, index|
        payload = edition.publishing_api_event.payload
        routing_key = edition.publishing_api_event.routing_key
        message = Streams::Messages::Factory.build(payload, routing_key)
        message.handler.reprocess

        puts "Updated editions #{index}" if (index % 5000).zero?
      end
    end

    puts "Done!"
  end

  desc "Update live attribute for unpublished editions"
  task unset_live_for_unpublished_editions: :environment do
    live_unpublished_editions = Dimensions::Edition.live.where(document_type: %w[gone vanish redirect])
    puts "Updating live #{live_unpublished_editions.count} editions"

    live_unpublished_editions.update_all(live: false)

    puts "Done!"
  end

  desc "Update live attribute for coming soon editions"
  task unset_live_for_coming_soon_editions: :environment do
    live_coming_soon_editions = Dimensions::Edition.live.where(document_type: "coming_soon")
    puts "Updating #{live_coming_soon_editions.count} live editions"

    live_coming_soon_editions.update_all(live: false)

    puts "Done!"
  end
end
