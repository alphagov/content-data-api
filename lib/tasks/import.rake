namespace :import do
  desc 'Import all content items for all organisations'
  task all_content_items: :environment do
    Content::Importers::AllContentItems.new.run
  end

  desc 'Import GA metrics '
  task all_ga_metrics: :environment do
    Content::Importers::AllGoogleAnalyticsMetrics.new.run
  end

  desc 'Load all metric facts'
  task daily_metrics: :environment do
    ETL::Metrics.process
  end
end
