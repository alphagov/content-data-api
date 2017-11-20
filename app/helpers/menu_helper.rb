module MenuHelper
  def navigation_link(text, url, scope)
    status = controller.controller_name == scope ? 'active' : ''

    content_tag :li, role: "presentation", class: status do
      link_to_unless_current text, url, aria_controls: "home", role: "tab", data: { test_id: scope } do
        link_to text, "#", aria_controls: "home", role: "tab"
      end
    end
  end
end
