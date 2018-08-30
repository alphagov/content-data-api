class Monitor::Dimensions
  def self.run(*args)
    new(*args).run
  end

  def run
    GovukStatsd.count('monitor.dimensions.base_path', Dimensions::Item.count)
    GovukStatsd.count('monitor.dimensions.latest_base_path', Dimensions::Item.where(latest: true).count)
  end
end
