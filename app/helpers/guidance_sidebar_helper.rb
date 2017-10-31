module GuidanceSidebarHelper
  def guidance_sidebar_headings(content)
    Nokogiri::HTML.fragment(content)
      .css('h2')
      .map { |h2| { id: h2.attr("id"), title: h2.text } }
  end
end
