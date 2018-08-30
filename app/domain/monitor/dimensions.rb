class Monitor::Dimensions
  def self.run(*args)
    new(*args).run
  end

  def run
    GovukStatsd.count('monitor.dimensions.base_path', Dimensions::Item.count)
  end
end
