class CSVExport
  def self.run(*args)
    new(*args).run
  end

  def initialize(scope, fields)
    @scope = scope
    @fields = fields
  end

  def run
    Enumerator.new do |enum|
      write_header(enum)
      scope.in_batches { |batch| write_batch(enum, batch) }
    end
  end

private

  def write_batch(enum, items)
    items.pluck(*fields).each do |item|
      enum << CSV::Row.new(fields, item).to_s
    end
  end

  attr_reader :scope, :fields

  def write_header(enum)
    enum << CSV::Row.new(fields, fields, true).to_s
  end
end
