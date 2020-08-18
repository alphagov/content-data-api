class Monitor::Dimensions
  include TraceAndRecoverable
  def self.run(*args)
    new(*args).run
  end

  def run
    trap do
      statsd_for_all_base_paths!
      statsd_for_live_base_paths!
      statsd_for_all_content_items!
      statsd_for_live_content_items!
    end
  end

private

  def statsd_for_live_base_paths!
    path = path_for("live_base_paths")
    count = Dimensions::Edition.live.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_all_base_paths!
    path = path_for("base_paths")
    count = Dimensions::Edition.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_live_content_items!
    path = path_for("live_content_items")
    count = Dimensions::Edition.live.count("distinct content_id")

    GovukStatsd.count(path, count)
  end

  def statsd_for_all_content_items!
    path = path_for("content_items")
    count = Dimensions::Edition.count("distinct content_id")

    GovukStatsd.count(path, count)
  end

  def path_for(item)
    "monitor.dimensions.#{item}"
  end
end
