module Audits
  RSpec.describe SerializeFilterToQueryParameters do
    let(:allocated_to) { double }
    let(:audit_status) { double }
    let(:document_type) { double }
    let(:organisations) { double }
    let(:primary_org_only) { double }
    let(:sort_by) { double }
    let(:title) { double }

    let(:filter) {
      double(
        allocated_to: allocated_to,
        audit_status: audit_status,
        document_type: document_type,
        organisations: organisations,
        primary_org_only: primary_org_only,
        sort_by: sort_by,
        title: title,
      )
    }

    describe '.call' do
      subject { described_class.new(filter).call }

      it 'returns a query parameters hash' do
        is_expected.to eq(
          allocated_to: allocated_to,
          audit_status: audit_status,
          document_type: document_type,
          organisations: organisations,
          primary: primary_org_only,
          query: title,
          sort_by: sort_by,
        )
      end
    end
  end
end
