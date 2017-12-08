RSpec.feature 'Audit metadata', type: :feature do
  scenario 'showing minimal metadata next to the audit questionnaire' do
    given_a_content_item_that_has_not_been_audited_or_assigned
    when_i_audit_the_content_item
    then_i_am_shown_that_the_content_item_is_assigned_to_no_one
    and_i_am_shown_that_the_content_item_is_not_audited_yet
    and_i_am_shown_the_content_type
    and_i_am_shown_that_the_content_is_guidance
    and_i_am_shown_that_the_content_has_not_had_a_major_update
    and_i_am_shown_that_the_content_has_no_organisations
    and_i_am_shown_that_the_content_has_no_policy_areas
    and_i_am_shown_that_the_content_has_not_been_withdrawn
    and_i_am_shown_that_the_content_has_no_topics
    and_i_am_shown_that_the_content_has_no_unique_page_views
  end

  scenario 'showing maximal metadata next to the audit questionnaire' do
    given_a_content_item_that_has_been_tagged_and_audited_and_assigned
    when_i_audit_the_content_item
    then_i_am_shown_that_the_content_item_has_been_assigned
    and_i_am_shown_that_the_content_item_has_been_audited
    and_i_am_shown_the_organisations_the_content_item_is_tagged_to
    and_i_am_shown_when_the_last_major_update_happened
    and_i_am_shown_the_content_type
    and_i_am_shown_that_the_content_is_guidance
    and_i_am_shown_the_topics_the_content_item_is_tagged_to
    and_i_am_shown_the_policy_areas_the_content_item_is_tagged_to
    and_i_am_shown_that_the_content_has_not_been_withdrawn
    and_i_am_shown_the_unique_page_views
  end

  around do |example|
    Timecop.freeze(2017, 1, 1) { example.run }
  end

  def given_a_content_item_that_has_been_tagged_and_audited_and_assigned
    auditor = create(
      :user,
      name: 'Harper Lee',
      organisation: create(:organisation, title: 'Authors'),
    )

    assignee = create(
      :user,
      name: 'Edd The Duck',
      organisation: create(:organisation, title: 'CBBC'),
    )

    @content_item = create(
      :content_item,
      document_type: 'guidance',
      one_month_page_views: 1234,
      six_months_page_views: 12345,
      public_updated_at: '2017-01-03',
    )

    create(
      :link,
      link_type: :organisations,
      source: @content_item,
      target: create(:content_item, title: 'Home office'),
    )

    create(
      :link,
      link_type: :topics,
      source: @content_item,
      target: create(:content_item, title: 'Borders'),
    )

    create(
      :link,
      link_type: :topics,
      source: @content_item,
      target: create(:content_item, title: 'Immigration'),
    )

    create(
      :link,
      link_type: :policy_areas,
      source: @content_item,
      target: create(:content_item, title: 'Borders and Immigration'),
    )

    create(:allocation, content_item: @content_item, user: assignee)
    create(:audit, content_item: @content_item, user: auditor)
  end

  def given_a_content_item_that_has_not_been_audited_or_assigned
    create(:user)

    @content_item = create(
      :content_item,
      document_type: 'guidance',
      public_updated_at: nil,
    )
  end

  def when_i_audit_the_content_item
    @audit_content_item = ContentAuditTool.new.audit_content_item
    @audit_content_item.load(content_id: @content_item.content_id)
  end

  def then_i_am_shown_that_the_content_item_is_assigned_to_no_one
    expect(@audit_content_item).to have_assigned_to(text: 'No one')
  end

  def then_i_am_shown_that_the_content_item_has_been_assigned
    expect(@audit_content_item)
      .to have_assigned_to(text: 'Edd The Duck')
  end

  def and_i_am_shown_that_the_content_item_is_not_audited_yet
    expect(@audit_content_item)
      .to have_audited(text: 'Not audited yet')
  end

  def and_i_am_shown_that_the_content_item_has_been_audited
    expect(@audit_content_item)
      .to have_audited(text: 'by Harper Lee ' \
                             'on 01/01/17 (less than a minute ago)')
  end

  def and_i_am_shown_the_content_type
    expect(@audit_content_item.metadata)
      .to have_content_type(text: 'Guidance')
  end

  def and_i_am_shown_that_the_content_has_not_had_a_major_update
    expect(@audit_content_item.metadata).to have_last_major_update(text: 'Never')
  end

  def and_i_am_shown_that_the_content_has_no_organisations
    expect(@audit_content_item.metadata).to have_organisations(text: 'None')
  end

  def and_i_am_shown_that_the_content_has_no_policy_areas
    expect(@audit_content_item.metadata).to have_policy_areas(text: 'None')
  end

  def and_i_am_shown_that_the_content_has_no_topics
    expect(@audit_content_item.metadata).to have_topics(text: 'None')
  end

  def and_i_am_shown_that_the_content_has_no_unique_page_views
    @audit_content_item.metadata do |metadata|
      expect(metadata)
        .to have_unique_page_views(text: '0 in the last month')

      expect(metadata)
        .to have_unique_page_views(text: '0 in the last six months')
    end
  end

  def and_i_am_shown_that_the_content_has_not_been_withdrawn
    expect(@audit_content_item.metadata).to have_withdrawn(text: 'No')
  end

  def and_i_am_shown_the_organisations_the_content_item_is_tagged_to
    expect(@audit_content_item.metadata)
      .to have_organisations(text: 'Home office')
  end

  def and_i_am_shown_when_the_last_major_update_happened
    expect(@audit_content_item.metadata)
      .to have_last_major_update(text: '03/01/17 (2 days ago)')
  end

  def and_i_am_shown_that_the_content_is_guidance
    expect(@audit_content_item.metadata).to have_content_type(text: 'Guidance')
  end

  def and_i_am_shown_the_topics_the_content_item_is_tagged_to
    expect(@audit_content_item.metadata)
      .to have_topics(text: 'Borders, Immigration')
  end

  def and_i_am_shown_the_policy_areas_the_content_item_is_tagged_to
    expect(@audit_content_item.metadata)
      .to have_policy_areas(text: 'Borders and Immigration')
  end

  def and_i_am_shown_the_unique_page_views
    @audit_content_item.metadata do |metadata|
      expect(metadata)
        .to have_unique_page_views(text: '1,234 in the last month')

      expect(metadata)
        .to have_unique_page_views(text: '12,345 in the last six months')
    end
  end
end
