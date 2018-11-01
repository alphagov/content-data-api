FactoryBot.define do
  factory :monthly_metric, class: 'Aggregations::MonthlyMetric' do
    transient do
      month { Dimensions::Month.build(Date.today).id }
      edition { create :edition }
    end

    dimensions_month { Dimensions::Month.build_from_string(month) }
    dimensions_edition { edition }

    pviews { 10 }
    upviews { 10 }
    feedex { 10 }
    useful_yes { 10 }
    useful_no { 10 }
    searches { 10 }
    exits { 10 }
    entrances { 10 }
    bounce_rate { 10 }
    avg_page_time { 10 }
    bounces { 10 }
    page_time { 10 }
    satisfaction { 10.0 }
  end
end
