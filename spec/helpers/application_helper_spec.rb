require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#order_link" do
    let(:organisation) { build(:organisation) }
    let(:link_label) { "Last Updated" }
    let(:path_params) {
      {
        organisation_id: organisation,
        sort: :public_updated_at,
      }
    }

    before do
      assign(:organisation, organisation)
    end

    it "returns ascending ordering link when order is not given " do
      expected_link = link_to(
        link_label,
        organisation_content_items_path(path_params.merge(order: :asc))
      )

      expect(helper.order_link(link_label, :public_updated_at, nil)).to eq(expected_link)
    end

    it "returns descending ordering link when order is asc" do
      expected_link = link_to(
        link_label,
        organisation_content_items_path(path_params.merge(order: :desc))
      )

      expect(helper.order_link(link_label, :public_updated_at, "asc")).to eq(expected_link)
    end

    it "returns ascending ordering link when order is desc" do
      expected_link = link_to(
        link_label,
        organisation_content_items_path(path_params.merge(order: :asc))
      )

      expect(helper.order_link(link_label, :public_updated_at, "desc")).to eq(expected_link)
    end
  end
end
