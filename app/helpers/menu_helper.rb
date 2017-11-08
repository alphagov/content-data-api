module MenuHelper
  def navigation_link(text, url, scope, data_test)
    status = controller.controller_name == scope ? 'active' : ''

    content_tag :li, role: "presentation", class: status, data: { test: data_test } do
      link_to_unless_current text, url, aria_controls: "home", role: "tab" do
        link_to text, "#", aria_controls: "home", role: "tab"
      end
    end
  end
end
