class Monitor::Dimensions
  def self.run(*args)
    new(*args).run
  end

  def run
    statsd_for_all_base_paths!
    statsd_for_latest_base_paths!

    statsd_for_all_content_items!
    statsd_for_latest_content_items!
  end

private

  def statsd_for_latest_base_paths!
    path = path_for('latest_base_path')
    count = Dimensions::Item.latest.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_all_base_paths!
    path = path_for('base_path')
    count = Dimensions::Item.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_latest_content_items!
    path = path_for('latest_content_items')
    count = Dimensions::Item.latest.count('distinct content_id')

    GovukStatsd.count(path, count)
  end

  def statsd_for_all_content_items!
    path = path_for('content_items')
    count = Dimensions::Item.count('distinct content_id')

    GovukStatsd.count(path, count)
  end

  def path_for(item)
    "monitor.dimensions.#{item}"
  end
end
