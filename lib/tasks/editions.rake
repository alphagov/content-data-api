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
end
