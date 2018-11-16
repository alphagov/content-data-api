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
      puts "repopulating GA pviews for #{date}"
      Etl::GA::ViewsAndNavigationProcessor.process(date: date)
      puts "finished repopulating GA pviews for #{date}"
    end
  end

  desc 'Delete existing metrics and Run Etl Master process across a range of dates'
  task :rerun_master, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date
    (from..to).each do |date|
      ActiveRecord::Base.transaction do
        puts "Deleting existing metrics for #{date}"
        Facts::Metric.where(dimensions_date_id: date).delete_all
        puts "Running Etl::Master process for #{date}"
        Etl::Master::MasterProcessor.process(date: date)
        puts "finished running Etl::Master for #{date}"
      end
    end
  end

  desc 'Populate GA metrics for a date'
  task :ga, [:date] => [:environment] do |_t, args|
    date = args[:date]
    GA.process(date: date.to_date)
  end
end
