class Reports::FindMetadata
  def self.run(base_path)
    latest_item = Dimensions::Edition.latest_by_base_path(base_path).first
    latest_item.nil? ? nil : latest_item.metadata
  end
end
