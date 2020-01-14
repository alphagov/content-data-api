namespace :etl do
  desc "Run ETL master process for yesterday"
  task master: :environment do
    unless Etl::Master::MasterProcessor.process
      abort("Etl::Master::MasterProcessor failed")
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
      console_log "repopulating Monthly Aggregation for #{string_date}"
      Etl::Aggregations::Monthly.process(date: date)
      console_log "finished repopulating Monthly Aggregation for #{string_date}"
    end
  end

  desc "Run Etl::Aggregations::Search"
  task repopulate_aggregations_search: :environment do
    console_log "repopulating Search Aggregations"
    Etl::Aggregations::Search.process
    console_log "finished repopulating Search Aggregations"
  end

  desc "Run Etl::GA::ViewsAndNavigationProcessor for range of dates"
  task :repopulateviews, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      console_log "repopulating GA pviews for #{date}"
      unless Etl::GA::ViewsAndNavigationProcessor.process(date: date)
        abort("Etl::GA::ViewsAndNavigationProcessor failed")
      end
      console_log "finished repopulating GA pviews for #{date}"
    end
  end

  desc "Run Etl::GA::InternalSearchProcessor for range of dates"
  task :repopulate_searches, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      console_log "repopulating searches for #{date}"
      unless Etl::GA::InternalSearchProcessor.process(date: date)
        abort("Etl::GA::InternalSearchProcessor failed")
      end
      console_log "finished repopulating searches for #{date}"
    end
  end

  desc "Run Etl::GA::UserFeedbackProcessor for range of dates"
  task :repopulate_useful, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      console_log "repopulating useful scores for #{date}"
      unless Etl::GA::UserFeedbackProcessor.process(date: date)
        abort("Etl::GA::UserFeedbackProcessor failed")
      end
      console_log "finished repopulating useful scores for #{date}"
    end
  end

  desc "Run Etl::Feedex::Processor for range of dates"
  task :repopulate_feedex, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      console_log "repopulating feedex for #{date}"
      unless Etl::Feedex::Processor.process(date: date)
        abort("Etl::Feedex::Processor failed")
      end
      console_log "finished repopulating feedex for #{date}"
    end
  end

  desc "Run ETL Master process across a range of dates"
  task :rerun_master, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    date_range = (from..to)
    date_range.each do |date|
      console_log "Running Etl::Master process for #{date}"
      unless Etl::Master::MasterProcessor.process(date: date)
        abort("Etl::Master::MasterProcessor failed")
      end
      console_log "finished running Etl::Master for #{date}"
    end

    extract_month_ends(date_range).each do |date|
      console_log "Running monthly and search aggregations for #{date}"
      Etl::Master::MasterProcessor.process_aggregations(date: date)
    end
  end

  desc "Populate GA metrics for a date"
  task :ga, [:date] => [:environment] do |_t, args|
    date = args[:date]
    GA.process(date: date.to_date)
  end

  def extract_month_ends(date_range)
    date_range.map(&:end_of_month).uniq
  end

  def console_log(str)
    puts str unless Rails.env.test?
  end
end
