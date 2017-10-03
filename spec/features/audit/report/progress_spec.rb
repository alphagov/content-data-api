RSpec.feature "Reporting on audit progress" do
  let!(:my_organisation) do
    create(
      :organisation
    )
  end

  let!(:me) do
    create(
      :user,
      organisation: my_organisation,
    )
  end

  context "I have been allocated some audited and unaudited content items belonging to my organisation" do
    before(:each) do
      content_items = create_list(
        :content_item,
        3,
        document_type: "transaction",
        allocated_to: me,
        primary_publishing_organisation: my_organisation,
      )

      create(:passing_audit, content_item: content_items[0])
      create(:failing_audit, content_item: content_items[1])
    end

    scenario "Displaying the number of items included in the audit" do
      visit audits_report_path

      expect(page).to have_content("3 Content items")

      select "Anyone", from: "allocated_to"
      select "Guide", from: "document_type"
      click_on "Apply filters"

      expect(page).to have_content("0 Content items")

      select "Transaction", from: "document_type"
      click_on "Apply filters"

      expect(page).to have_content("3 Content items")
    end

    scenario "Displaying the number of items audited/not audited" do
      visit audits_report_path

      expect(page).to have_content("Audited 2 67%")
      expect(page).to have_content("Still to audit 1 33%")
      expect(width("#progress")).to eq("width: 66.66667%;")
    end

    scenario "Displaying the number of items needing improvement/not needing improvement" do
      visit audits_report_path

      expect(page).to have_content("Need improvement 1 50%")
      expect(page).to have_content("Don't need improvement 1 50%")
      expect(width("#items-needing-improvement")).to eq("width: 50%;")
    end
  end

  scenario "Audit status filter is not present" do
    visit audits_report_path

    expect(page).to have_no_content("Audit status")
  end

  def width(id)
    page.find("#{id} .progress .progress-bar")[:style]
  end
end
