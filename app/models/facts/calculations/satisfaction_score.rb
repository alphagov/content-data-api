class Facts::Calculations::SatisfactionScore
  def self.apply(metric)
    metric.satisfaction_score = if metric.is_this_useful_yes.nil? && metric.is_this_useful_no.nil?
                                  nil
                                elsif metric.is_this_useful_yes.nil? || metric.is_this_useful_yes.zero?
                                  0.0
                                elsif metric.is_this_useful_no.nil? || metric.is_this_useful_no.zero?
                                  1.0
                                else
                                  metric.is_this_useful_yes.to_f / (metric.is_this_useful_yes + metric.is_this_useful_no).to_f
                                end
  end
end
