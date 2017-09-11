RSpec.feature "Allocate content to other content auditors", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  let(:current_user) { User.first }
  let(:organisation_slug) { current_user.organisation_slug }

  before do
    create :allocation, user: current_user
  end

  scenario "List content auditors of same organisation" do
    create :user, :with_allocated_content, name: "John Smith", organisation_slug: organisation_slug
    create :user, :with_allocated_content, name: "Arthur Johnson", organisation_slug: organisation_slug

    visit audits_allocations_path

    options = [
      "Me",
      "Anyone",
      "No one",
      "Arthur Johnson",
      "John Smith",
    ]
    expect(page).to have_select("allocated_to", options: options)
  end

  scenario "Allocate content to other content auditors" do
    create :user, :with_allocated_content, name: "John Smith", organisation_slug: organisation_slug
    create :content_item, title: "content item 1", content_id: "content-id-1"
    create :content_item, title: "content item 2"

    visit audits_allocations_path(allocated_to: "anyone")

    check option: "content-id-1"

    select "John Smith", from: "allocate_to"
    click_on "Go"

    expect(page).to have_content("1 items allocated to John Smith")

    select "John Smith", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")
  end
end
