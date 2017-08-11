namespace :report do
  desc "Precompute report rows for all content items"
  task precompute: :environment do
    out_of = Content::Item.count
    count = 0

    Content::Item.find_each do |content_item|
      Audits::ReportRow.precompute(content_item)

      count += 1

      if (count % 500).zero?
        puts "#{count} / #{out_of} (#{(count.to_f / out_of * 100).round(2)}%)"
      end
    end
  end
end
