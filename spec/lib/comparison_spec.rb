RSpec.describe Comparison do
  let!(:first) { FactoryGirl.create(:content_item, base_path: "/first") }
  let!(:third) { FactoryGirl.create(:content_item, base_path: "/third") }

  before do
    policy = FactoryGirl.create(:content_item)

    FactoryGirl.create(
      :theme,
      name: "Transport",
      subthemes: [
        FactoryGirl.create(
          :subtheme,
          name: "Driving",
          inventory_rules: [
            FactoryGirl.create(
              :inventory_rule,
              link_type: "policies",
              target_content_id: policy.content_id,
            ),
          ],
        ),
      ],
    )

    FactoryGirl.create(:link, source: first, target: policy, link_type: "policies")
    FactoryGirl.create(:link, source: third, target: policy, link_type: "policies")
  end

  let(:fixture) { "#{Rails.root}/spec/fixtures/transport.csv" }

  it "computes the difference between the theme and the csv" do
    comparison = described_class.new(fixture, "Transport")

    expect(comparison.base_paths_missing_from_theme).to eq %w(/second)
    expect(comparison.base_paths_missing_from_csv).to eq %w(/third)
  end

  it "removes /government prefixes as these don't appear in the csv" do
    third.update!(base_path: "/government/third")

    comparison = described_class.new(fixture, "Transport")

    expect(comparison.base_paths_missing_from_csv).to eq %w(/third)
  end
end
