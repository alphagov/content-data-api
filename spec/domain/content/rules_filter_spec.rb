RSpec.describe Content::RulesFilter do
  subject { described_class.new(rules: subtheme.inventory_rules) }

  let(:subtheme) { create(:subtheme) }
  let(:result) { subject.apply(ContentItem.all).map(&:title) }

  def rule(type, target)
    create(
      :inventory_rule,
      subtheme: subtheme,
      link_type: type,
      target_content_id: target.content_id,
    )
  end

  let!(:hmrc) { create(:content_item, title: "HMRC") }
  let!(:raib) { create(:content_item, title: "RAIB") }

  let!(:vat) { create(:content_item, title: "VAT") }
  let!(:rail) { create(:content_item, title: "Railways") }

  let!(:a) do
    create(:content_item, title: "a", organisations: hmrc, policies: vat)
  end

  let!(:b) do
    create(:content_item, title: "b", organisations: hmrc, policies: rail)
  end

  let!(:c) do
    create(:content_item, title: "c", organisations: raib, policies: rail)
  end

  it "filters content items for a single inventory rule" do
    rule("organisations", hmrc)
    expect(result).to match_array %w(a b)
  end

  it "filters content items for multiple rules of the same type" do
    rule("organisations", hmrc)
    rule("organisations", raib)

    expect(result).to match_array %w(a b c)
  end

  it "filters content items for multiple, single rules of different types" do
    rule("organisations", hmrc)
    rule("policies", rail)

    expect(result).to match_array %w(a b c)
  end

  it "doesn't filter items where the filter does not match a link type" do
    rule("related", hmrc)

    expect(result).to be_empty
  end
end
