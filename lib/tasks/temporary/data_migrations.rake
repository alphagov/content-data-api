namespace :data_migrations do
  desc 'Calculate satisfaction score for all existing metrics that have `is this useful?` values'
  task update_satisfaction: :environment do
    metrics = Facts::Metric.where.not(is_this_useful_yes: nil).or(Facts::Metric.where.not(is_this_useful_no: nil))

    metrics.find_each do |metric|
      Facts::Calculations::SatisfactionScore.apply(metric)
      metric.save
      print '.'
    end
  end
end
