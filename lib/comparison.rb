class Comparison
  attr_accessor :csv, :theme

  def self.print(*args)
    comparison = new(*args)

    base_paths = comparison.base_paths_missing_from_theme
    puts "There are #{base_paths.count} base paths missing from the theme:"
    puts base_paths.map { |p| "  #{p}" }

    base_paths = comparison.base_paths_missing_from_csv
    puts "There are #{base_paths.count} base paths missing from the csv:"
    puts base_paths.map { |p| "  #{p}" }
  end

  def initialize(csv_path, theme_name)
    self.csv = CSV.read(csv_path)
    self.theme = Theme.find_by!(name: theme_name)

    compute_additions_and_deletions
  end

  def base_paths_missing_from_theme
    deletions
  end

  def base_paths_missing_from_csv
    additions
  end

private

  attr_accessor :additions, :deletions

  def compute_additions_and_deletions
    self.additions = base_paths_in_theme - base_paths_in_csv
    self.deletions = base_paths_in_csv - base_paths_in_theme
  end

  def base_paths_in_theme
    @base_paths_in_theme ||= begin
      query = Search::QueryBuilder.new
        .theme("Theme_#{theme.id}")
        .build

      search = Search.new(query)

      items = search.unpaginated
      paths = items.pluck(:base_path)
      normalise(paths)
    end
  end

  def base_paths_in_csv
    @base_paths_in_csv ||= (
      paths = csv.map(&:first)[1..-1]
      normalise(paths)
    )
  end

  def normalise(base_paths)
    base_paths.compact
      .map { |p| p.sub(/^.*gov\.uk/, "") }
      .map { |p| p.sub(/^\/government/, "") }
  end
end
