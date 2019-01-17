FactoryBot.define do
  factory :monthly_metric, class: 'Aggregations::MonthlyMetric' do
    transient do
      month { Dimensions::Month.build(Date.today).id }
      edition { create :edition }
    end

    dimensions_month do
      y, m = *month.split('-').map(&:to_i)

      Dimensions::Month.find_or_create(Date.new(y, m, 1))
    end

    dimensions_edition { edition }

    pviews { 10 }
    upviews { 10 }
    feedex { 10 }
    useful_yes { 10 }
    useful_no { 10 }
    searches { 10 }
    exits { 10 }
    entrances { 10 }
    bounces { 10 }
    page_time { 10 }
    satisfaction { 10.0 }
  end
end
