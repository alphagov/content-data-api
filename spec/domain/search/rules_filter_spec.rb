RSpec.describe Search::RulesFilter do
  subject { described_class.new(rules: subtheme.inventory_rules) }

  let(:subtheme) { create(:subtheme) }
  let(:result) { subject.apply(ContentItem.all).map(&:title) }

  def node(title)
    create(:content_item, title: title)
  end

  def edge(source, target, type)
    create(:link, source: source, target: target, link_type: type)
  end

  def rule(type, target)
    create(
      :inventory_rule,
      subtheme: subtheme,
      link_type: type,
      target_content_id: target.content_id,
    )
  end

  let!(:a) { node("a") }
  let!(:b) { node("b") }
  let!(:c) { node("c") }

  let!(:hmrc) { node("HMRC") }
  let!(:raib) { node("RAIB") }

  let!(:vat) { node("VAT") }
  let!(:rail) { node("Railways") }

  before do
    edge(a, hmrc, "organisations")
    edge(b, hmrc, "organisations")
    edge(c, raib, "organisations")

    edge(a, vat, "policies")
    edge(b, rail, "policies")
    edge(c, rail, "policies")
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
