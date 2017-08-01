RSpec.describe Audits::ContentQuery do
  let!(:content_item) { create(:content_item) }
  let!(:audit) { create(:audit, content_item: content_item) }

  it "can filter by audit status" do
    subject.audit_status(:audited)
    expect(subject.scope).to eq [content_item]
  end

  it "can filter by passing status" do
    create(
      :response,
      question: create(:boolean_question),
      audit: audit,
      value: "no",
    )

    subject.passing
    expect(subject.scope).to eq [content_item]
  end

  it "can filter by failing status" do
    create(
      :response,
      question: create(:boolean_question),
      audit: audit,
      value: "yes",
    )

    subject.failing
    expect(subject.scope).to eq [content_item]
  end
end
