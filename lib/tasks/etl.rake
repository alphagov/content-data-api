namespace :etl do
  desc 'Run ETL master process'
  task master: :environment do
    ETL::Master.process
  end
end
