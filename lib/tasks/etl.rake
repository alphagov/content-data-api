namespace :etl do
  desc 'Run ETL master process'
  task master: :environment do
    Etl::Master::MasterProcessor.process
  end

  desc 'Run Etl::GA::ViewsAndNavigationProcessor for range of dates'
  task :repopulateviews, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      console_log "repopulating GA pviews for #{date}"
      Etl::GA::ViewsAndNavigationProcessor.process(date: date)
      console_log "finished repopulating GA pviews for #{date}"
    end
  end

  desc 'Delete existing metrics and Run Etl Master process across a range of dates'
  task :rerun_master, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    date_range = (from..to)
    date_range.each do |date|
      ActiveRecord::Base.transaction do
        console_log "Deleting existing metrics for #{date}"
        Facts::Metric.where(dimensions_date_id: date).delete_all
        console_log "Running Etl::Master process for #{date}"
        Etl::Master::MasterProcessor.process(date: date)
        console_log "finished running Etl::Master for #{date}"
      end
    end

    extract_month_ends(date_range).each do |date|
      console_log "Running monthly and search aggregations for #{date}"
      Etl::Master::MasterProcessor.process_aggregations(date: date)
    end
  end

  desc 'Populate GA metrics for a date'
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
