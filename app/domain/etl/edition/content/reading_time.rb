class Etl::Edition::Content::ReadingTime
  def self.calculate(words)
    # 200 words per minute. Rounds up to 1 anything less than 1 minute.
    (words / 200.00).ceil
  end
end
