RSpec.feature "Audit metadata", type: :feature do
  let!(:my_organisation) do
    create(
      :organisation,
      title: "Authors",
    )
  end

  let!(:me) do
    create(
      :user,
      name: "Harper Lee",
      organisation: my_organisation,
    )
  end

  let!(:content_item) do
    create(
      :content_item,
      public_updated_at: nil,
      document_type: "document_collection",
    )
  end

  around do |example|
    Timecop.freeze(2017, 1, 1) { example.run }
  end

  scenario "showing minimal metadata next to the audit quesionnaire" do
    @audit_content_item = ContentAuditTool.new.audit_content_item
    @audit_content_item.load(content_id: content_item.content_id)

    @audit_content_item.metadata do |metadata|
      expect(metadata).to have_assigned_to(text: 'No one')
      expect(metadata).to have_audited(text: 'Not audited yet')
      expect(metadata).to have_content_type(text: 'Document Collection')
      expect(metadata).to have_guidance(text: 'No')
      expect(metadata).to have_last_major_update(text: 'Never')
      expect(metadata).to have_organisations(text: 'None')
      expect(metadata).to have_policy_areas(text: 'None')
      expect(metadata).to have_topics(text: 'None')
      expect(metadata).to have_unique_page_views(text: '0 in the last month')
      expect(metadata).to have_unique_page_views(text: '0 in the last six months')
      expect(metadata).to have_withdrawn(text: 'No')
    end
  end

  def create_linked_content(link_type, title)
    target = create(:content_item, title: title)

    create(
      :link,
      link_type: link_type,
      source_content_id: content_item.content_id,
      target_content_id: target.content_id,
    )
  end

  scenario "showing maximal metadata next to the audit questionnaire" do
    content_item.update!(
      public_updated_at: "2017-01-03",
      one_month_page_views: 1234,
      six_months_page_views: 12345,
      document_type: "guidance",
    )

    create(:audit, content_item: content_item, user: me)

    create_linked_content("organisations", "Home office")
    create_linked_content("topics", "Immigration")
    create_linked_content("topics", "Borders")
    create_linked_content("policy_areas", "Borders and Immigration")

    cbbc = create(:organisation, title: "CBBC")
    edd_the_duck = create(:user, name: "Edd the Duck", organisation: cbbc)

    create(:allocation, content_item: content_item, user: edd_the_duck)

    @audit_content_item = ContentAuditTool.new.audit_content_item
    @audit_content_item.load(content_id: content_item.content_id)

    @audit_content_item.metadata do |metadata|
      expect(metadata).to have_assigned_to(
                            text: 'Edd the Duck CBBC',
                          )

      expect(metadata).to have_audited(
                            text: '01/01/17 (less than a minute ago) ' \
                                  'by Harper Lee Authors',
                          )

      expect(metadata).to have_organisations(text: 'Home office')
      expect(metadata).to have_last_major_update(text: '03/01/17 (2 days ago)')
      expect(metadata).to have_content_type(text: 'Guidance')
      expect(metadata).to have_guidance(text: 'Yes')
      expect(metadata).to have_topics(text: 'Borders, Immigration')
      expect(metadata).to have_policy_areas(text: 'Borders and Immigration')
      expect(metadata).to have_withdrawn(text: 'No')
      expect(metadata).to have_unique_page_views(text: '1,234 in the last month')
      expect(metadata).to have_unique_page_views(text: '12,345 in the last six months')
    end
  end
end
