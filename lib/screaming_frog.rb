class ScreamingFrog
  INPUT_HEADERS = [
    "URL",
    "Title",
    "Character Length",
    "Pixel Length",
    "Description"
  ].freeze

  def initialize(input_stream, output_stream: STDOUT)
    @input_csv = CSV.new(
      input_stream
    )

    # The first 3 lines are garbage, the 4th is the real header
    @input_csv = @input_csv.drop(4)

    @output_csv = CSV.new(output_stream, headers: true)

    @output_csv << INPUT_HEADERS + [
      "Pageviews Last 6 Months",
      "Document Type",
      "Primary Publishing Organisation"
    ]

    @content_lookup = {}

    fetch_all_the_things
  end

  def write
    progressbar = ProgressBar.create
    progressbar.total = 145377

    input_csv.each do |row|
      progressbar.increment

      row = INPUT_HEADERS.zip(row).to_h
      uri = URI(URI.encode(row["URL"]))
      next if uri.host.present? && uri.host != 'www.gov.uk'

      # Ignore withdrawn content for now
      next if /\[Withdrawn\]/ =~ row["Title"]

      base_path = uri.path
      binding.pry if base_path.nil?

      # The crawler has a URL for every locale, but content performance
      # manager may only have the english translation. Use this as a fallback.
      locale_free_path = base_path.sub(/\.[a-z]{2}(-\d{3})?$/, '')

      parts = base_path.split("/")
      parts.pop
      shorter_base_path = parts.join("/")

      possible_content_items = [base_path, locale_free_path, shorter_base_path]
      content_item = nil

      possible_content_items.each do |possible_content_item|
        content_item = content_lookup[possible_content_item]

        break unless content_item.nil?
      end

      # Remove newlines: some tools that import CSV don't like them
      row["Description"] = row["Description"].squish

      if content_item.nil?
        output_csv << row.merge({
          "Pageview Last 6 Months" => "UNKNOWN",
          "Document Type" => "UNKNOWN",
          "Primary Publishing Organisation" => "UNKNOWN"
        })
      else
        document_type, six_months_page_views, primary_publishing_organisation = content_item

        output_csv << row.merge({
          "Pageviews Last 6 Months" => six_months_page_views,
          "Document Type" => document_type,
          "Primary Publishing Organisation" => primary_publishing_organisation || "UNKNOWN"
        })
      end
    end

    progressbar.finish
  end

  def self.enhance(filename, output_filename)
    input_stream = File.open(filename)
    output_stream = File.open(output_filename, 'wb')
    ScreamingFrog.new(input_stream, output_stream: output_stream).write
  end

private

  attr_reader :input_csv, :output_csv, :content_lookup


  def fetch_all_the_things
    organisations_lookup = {}
    organisations = Content::Link.where(link_type: [:organisations, :worldwide_organisations]).group(:target_content_id).count

    # Query all organisation and worldwide organisation links
    # Use these as a fallback for when primary publishing organisation isn't set
    organisation_links = Content::Link
      .where(link_type: [:organisations, :worldwide_organisations])
      .joins("JOIN content_items ON (links.target_content_id=content_items.content_id)")
      .pluck(:source_content_id, :target_content_id, "content_items.base_path")

    organisation_links.each do |source, target, title|
      prolificness = organisations[target]

      organisations_lookup[source] ||= []
      organisations_lookup[source] << [title, prolificness]
    end

    content_items = Content::Item
      .joins("LEFT JOIN links ON (links.source_content_id=content_items.content_id AND links.link_type='primary_publishing_organisation')")
      .joins("LEFT JOIN content_items AS organisations ON (links.target_content_id = organisations.content_id)")
      .pluck(:content_id, :base_path, :document_type, :six_months_page_views, "organisations.base_path")

    content_items.each do |content_id, base_path, document_type, six_months_page_views, primary_publishing_organisation|
      unless primary_publishing_organisation.present?
        organisations = organisations_lookup[content_id]

        if organisations.present?
          # Assume the biggest organisation owns it
          primary_publishing_organisation = organisations.max_by(&:second).first
        end
      end

      content_lookup[base_path] = [document_type, six_months_page_views, primary_publishing_organisation]
    end
  end
end
