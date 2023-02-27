namespace :etl do
  desc "Run ETL main process for yesterday"
  task main: :environment do
    unless Etl::Main::MainProcessor.process
      abort("Etl::Main::MainProcessor failed")
    end
  end

  desc "Run Etl::Aggregations::Monthly for range of dates"
  task :repopulate_aggregations_month, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    months = (from..to).map { |d| [d.year, d.month] }.uniq

    months.each do |month|
      date = Date.new(*month, 1)
      string_date = date.strftime("%Y-%m")
      puts "repopulating Monthly Aggregation for #{string_date}"
      Etl::Aggregations::Monthly.process(date:)
      puts "finished repopulating Monthly Aggregation for #{string_date}"
    end
  end

  desc "Run Etl::Aggregations::Search"
  task repopulate_aggregations_search: :environment do
    puts "repopulating Search Aggregations"
    Etl::Aggregations::Search.process
    puts "finished repopulating Search Aggregations"
  end

  desc "Run Etl::GA::ViewsAndNavigationProcessor for range of dates"
  task :repopulateviews, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      puts "repopulating GA pviews for #{date}"
      unless Etl::GA::ViewsAndNavigationProcessor.process(date:)
        abort("Etl::GA::ViewsAndNavigationProcessor failed")
      end
      puts "finished repopulating GA pviews for #{date}"
    end
  end

  desc "Run Etl::GA::InternalSearchProcessor for range of dates"
  task :repopulate_searches, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      puts "repopulating searches for #{date}"
      unless Etl::GA::InternalSearchProcessor.process(date:)
        abort("Etl::GA::InternalSearchProcessor failed")
      end
      puts "finished repopulating searches for #{date}"
    end
  end

  desc "Run Etl::GA::UserFeedbackProcessor for range of dates"
  task :repopulate_useful, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      puts "repopulating useful scores for #{date}"
      unless Etl::GA::UserFeedbackProcessor.process(date:)
        abort("Etl::GA::UserFeedbackProcessor failed")
      end
      puts "finished repopulating useful scores for #{date}"
    end
  end

  desc "Run Etl::Feedex::Processor for range of dates"
  task :repopulate_feedex, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      puts "repopulating feedex for #{date}"
      unless Etl::Feedex::Processor.process(date:)
        abort("Etl::Feedex::Processor failed")
      end
      puts "finished repopulating feedex for #{date}"
    end
  end

  desc "Run ETL Main process across a range of dates"
  task :rerun_main, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    date_range = (from..to)
    date_range.each do |date|
      puts "Running Etl::Main process for #{date}"
      unless Etl::Main::MainProcessor.process(date:)
        abort("Etl::Main::MainProcessor failed")
      end
      puts "finished running Etl::Main for #{date}"
    end

    month_ends = date_range.map(&:end_of_month).uniq
    month_ends.each do |date|
      puts "Running monthly and search aggregations for #{date}"
      Etl::Main::MainProcessor.process_aggregations(date:)
    end
  end

  desc "Populate GA metrics for a date"
  task :ga, [:date] => [:environment] do |_t, args|
    date = args[:date]
    GA.process(date: date.to_date)
  end
end
