require 'ruby-progressbar/outputs/null'

namespace :etl do
  desc 'Populate document_text property for items which have no content'
  task populate_content: :environment do
    process
  end

  def process
    scope = Dimensions::Item.where(document_text: nil)

    options = { total: scope.count }
    options[:output] = ProgressBar::Outputs::Null if Rails.env.test?

    progress_bar = ProgressBar.create(options)
    scope.find_each do |item|
      item.update document_text: Etl::Item::Content::Parser.extract_content(item.raw_json)
      progress_bar.increment
    end
  end
end
