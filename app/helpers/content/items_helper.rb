module Content::ItemsHelper
  def advanced_filter_enabled?
    params[:taxons].present?
  end

  def content_metadata
    [
      {
        title: "Topics",
        content: content_item.topics,
        test_id: "topics",
      },
      {
        title: "Unique pageviews",
        content: [
          "#{content_item.one_month_page_views} in the  last month",
          "#{content_item.six_months_page_views} in the last six months",
        ],
        test_id: "pageviews",
      },
    ]
  end

  def hidden_content_metadata
    [
      {
        title: "Organisations",
        content: content_item.organisations,
        test_id: "organisations",
      },
      {
        title: "Last major update",
        content: content_item.last_updated,
        test_id: "last-updated",
      },
      {
        title: "Content type",
        content: content_item.document_type,
        test_id: "content-type",
      },
      {
        title: "Guidance",
        content: content_item.guidance,
        test_id: "guidance",
      },
      {
        title: "Policy areas",
        content: content_item.policy_areas,
        test_id: "policy-areas",
      },
      {
        title: "Withdrawn",
        content: content_item.withdrawn,
        test_id: "withdrawn",
      },
    ]
  end

  def assigned_to_current_user
    content_item.allocation&.user == current_user
  end
end
