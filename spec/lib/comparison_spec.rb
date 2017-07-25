RSpec.describe Comparison do
  let!(:policy) { create(:content_item) }
  let!(:first) { create(:content_item, base_path: "/first", policies: policy) }
  let!(:third) { create(:content_item, base_path: "/third", policies: policy) }

  before do
    create(
      :theme,
      name: "Transport",
      subthemes: [
        create(
          :subtheme,
          name: "Driving",
          inventory_rules: [
            create(
              :inventory_rule,
              link_type: "policies",
              target_content_id: policy.content_id,
            ),
          ],
        ),
      ],
    )
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
