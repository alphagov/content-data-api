class Finders::Metadata
  def self.run(base_path)
    live_item = Dimensions::Edition.live_by_base_path(base_path).first
    live_item.nil? ? nil : live_item.metadata
  end
end
