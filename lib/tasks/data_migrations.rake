namespace :data_migrations do
  desc 'Sets all metrics with no useful yes/no responses to have null for satisfaction'
  task satisfaction_defaults_to_null: :environment do
    puts "Setting default satisfaction to nil for pages with no responses"

    zero_responses = Facts::Metric.where('useful_yes = 0').where('useful_no = 0')

    zero_responses.in_batches.each_with_index do |metrics, batch_index|
      puts "Updating #{batch_index} records"
      metrics.update_all(satisfaction: nil)
    end

    puts "END"
  end
end
