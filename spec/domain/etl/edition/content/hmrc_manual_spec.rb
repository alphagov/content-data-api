RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'hmrc_manual'" do
    json = { schema_name: "hmrc_manual",
             title: "HMRC Manual",
             description: "Manual of items",
             details: {
               child_section_groups: [{
                 child_sections: [
                   { section_id: "ARG6757", title: "Section 1" },
                   { section_id: "THP8972", title: "Section 2" },
                 ],
               },
                                      {
                                        child_sections: [
                                          { section_id: "UP4591", title: "Section 15" },
                                        ],
                                        title: "Update",
                                      }],
             } }
    expected = "HMRC Manual Manual of items ARG6757 Section 1 THP8972 Section 2 Update UP4591 Section 15"
    expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
  end
end
