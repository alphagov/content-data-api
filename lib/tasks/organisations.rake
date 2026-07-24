namespace :organisations do
  desc "Identify organisations missing from CDA and provide replay instructions"
  task check_missing: :environment do
    known_missing = %w[
      1390d07f-12b3-4f55-9dd5-fec5fd9e3649
      63953ed9-98ac-4d08-a1b9-8ea38dbd0832
      99a5828c-79dd-4533-ab18-18069be289cf
    ]

    puts "Checking for missing organisations..."
    puts

    still_missing = known_missing.reject do |content_id|
      Dimensions::Edition.exists?(content_id:, live: true)
    end

    if still_missing.empty?
      puts "All organisations are present and live. Nothing to do."
    else
      puts "#{still_missing.size} organisation(s) still missing from CDA:"
      puts
      still_missing.each do |content_id|
        edition = Dimensions::Edition.find_by(content_id:)
        status = if edition
                   "exists but live=#{edition.live}"
                 else
                   "no record"
                 end
        puts "  #{content_id} (#{status})"
      end
      puts
      puts "To fix, run the following on Publishing API console:"
      puts
      puts "  %w[#{still_missing.join(' ')}].each do |content_id|"
      puts "    Commands::V2::RepresentDownstream.new.call(content_id)"
      puts "  end"
      puts
      puts "Then re-run this task to verify."
    end
  end
end
