RSpec.feature "Using guidance while auditing a content item", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  let!(:content_item) do
    create(
      :content_item,
      title: "Flooding",
      description: "All about flooding.",
      base_path: "/flooding",
      publishing_app: "whitehall",
    )
  end

  scenario "finding the guidance page" do
    visit content_item_audit_path(content_item)

    expect(page).to have_link("Audit guidance")

    click_link("Audit guidance")

    expect(page).to have_current_path("/audits/guidance")
    expect(page).to have_css("h1")
    expect(page).to have_content("Audit GOV.UK content")
  end
end
