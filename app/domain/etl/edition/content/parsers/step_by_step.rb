class Etl::Edition::Content::Parsers::StepByStep
  def parse(json)
    html = []

    steps = json.dig("details", "step_by_step_nav")

    if steps.present?
      html << steps["title"]
      html << steps["introduction"]
      chapters = steps["steps"]

      if chapters.present?
        html << get_chapters(chapters)
      end
    end

    html.compact.join(" ")
  end

  def schemas
    %w[step_by_step_nav]
  end

  def get_chapters(json_chapters)
    html = []

    json_chapters.each do |chapter|
      html << chapter["title"]
      contents = chapter["contents"]
      html << get_steps(contents) if contents.present?
    end

    html.compact
  end

  def get_steps(json_content)
    html = []

    json_content.each do |content|
      html << content["text"]
      lists = content["contents"]
      html << get_sub_steps(lists) if lists.present?
    end

    html.compact
  end

  def get_sub_steps(json_list)
    html = []

    json_list.each do |list|
      html << list["text"]
    end

    html.compact
  end
end
