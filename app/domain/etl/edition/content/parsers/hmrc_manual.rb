class Etl::Edition::Content::Parsers::HMRCManual
  def parse(json)
    html = []
    html << json.dig("title") unless json.dig("title").nil?
    html << json.dig("description") unless json.dig("description").nil?
    groups = json.dig("details", "child_section_groups")
    unless groups.nil?
      groups.each do |group|
        html << group["title"] unless group["title"].nil?
        sections = group["child_sections"]
        next if sections.nil?

        sections.each do |section|
          html << section["section_id"]
          html << section["title"]
        end
      end
    end
    html.join(" ") unless html.empty?
  end

  def schemas
    %w[hmrc_manual]
  end
end
