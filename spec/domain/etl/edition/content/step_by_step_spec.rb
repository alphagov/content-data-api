RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'step_by_step_nav'" do
    json = { schema_name: "step_by_step_nav",
             details: { step_by_step_nav: {
               title: "Learn to drive a car: step by step",
               introduction: "It's easy",
               steps: [{ title: "Step 1",
                         contents: [{ text: "Enter vehicle" }, contents: [{ text: "A" }, { text: "B" }, { text: "C" }]] },
                       { title: "Step 2",
                         contents: [{ text: "Adjust seat" }, contents: [{ text: "Z" }, { text: "Y" }, { text: "X" }]] }],
             } } }

    expected = "Learn to drive a car: step by step It's easy Step 1 Enter vehicle A B C Step 2 Adjust seat Z Y X"
    expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
  end
end
