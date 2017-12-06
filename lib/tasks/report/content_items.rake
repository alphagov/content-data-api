namespace :report do
  task content_items: :environment do
    puts "\n--- REPORT ---"
    puts "--- views = Six months page views ---"

    # Number of content items with no views
    content_items_no_views = Content::Item.where(six_months_page_views: 0)
    puts "Number of content items with no views: #{content_items_no_views.count}"

    # Number of content items with less than 10 views
    content_items_lt_10_views = Content::Item.where("six_months_page_views < 10")
    puts "Number of content items with less than 10 views: #{content_items_lt_10_views.count}"

    # Number of content items with no views categorised by format
    content_items_by_format = content_items_no_views.group(:document_type).order(:document_type)
    puts "Number of content items with no views categorised by format: \n#{content_items_by_format.count.map { |k, v| [k, v].join(' => ') }.join('\n')}"

    # Number of content items with no views that have never been updated in 6 months
    months = 6
    content_items_not_updated = content_items_no_views.where("public_updated_at < ?", Date.today - months.months)
    puts "Number of content items with no views that have never been updated in #{months} months: #{content_items_not_updated.count}"

    # Number of content items with no views categorised by department
    content_items_by_department = Content::Link.where(link_type: 'organisation')
        .where(source_content_id: content_items_no_views.pluck(:content_id))
        .group(:target_content_id).count
        .map { |k, v| [Content::Item.find_by(content_id: k).title, v].join(' => ') }
        .join('\n')
    puts "Number of content items with no views categorised by department: \n#{content_items_by_department}"
  end
end
