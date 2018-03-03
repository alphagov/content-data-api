class Queries::Metrics
  attr_reader :relation

  def initialize(relation = Facts::Metric.all)
    @relation = relation.
      joins(:dimensions_date).
      joins(:dimensions_item)
  end

  def between(from, to)
    join(from, to) do
      relation.where('dimensions_dates.date BETWEEN ? AND ?', from, to)
    end
  end

  def by_base_path(base_path)
    join(base_path) do
      relation.where('dimensions_items.base_path like (?)', base_path)
    end
  end

  def build
    relation
  end

private

  def join(*params)
    return self unless params.all?(&:present?)

    @relation = yield
    self
  end
end
