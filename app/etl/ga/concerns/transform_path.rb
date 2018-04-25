require 'active_support/concern'

module GA::Concerns::TransformPath
  extend ActiveSupport::Concern

  def fix_invalid_prefix_in_page_paths
    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    log(process: :ga, message: "Transforming #{events_with_prefix.count} events with page_path starting https://gov.uk")
    events_with_prefix.find_each do |event|
      page_path_without_prefix = event.page_path.remove '/https://www.gov.uk'
      event.update_attributes(page_path: page_path_without_prefix)
    end
  end
end
