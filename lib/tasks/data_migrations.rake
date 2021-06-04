DATA_MIGRATION_BATCH_SIZE = 25_000

namespace :data_migrations do
  desc "Sets all metrics with no useful yes/no responses to have null for satisfaction"
  task :satisfaction_defaults_to_null, %i[from to] => [:environment] do |_t, args|
    from = args[:from].to_date
    to = args[:to].to_date

    (from..to).each do |date|
      puts "Setting default satisfaction to nil for pages with no responses for #{date}"

      Facts::Metric
        .where(useful_yes: 0, useful_no: 0)
        .where(dimensions_date: Dimensions::Date.find(date))
        .in_batches(of: DATA_MIGRATION_BATCH_SIZE)
        .each_with_index do |metrics, index|
          puts "Updating batch of #{(index + 1) * DATA_MIGRATION_BATCH_SIZE} records"
          metrics.update_all(satisfaction: nil)
        end

      puts "END"
    end
  end
end
