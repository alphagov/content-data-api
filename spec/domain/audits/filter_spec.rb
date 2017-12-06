module Audits
  RSpec.describe Filter do
    it { is_expected.to respond_to(:after) }
    it { is_expected.to respond_to(:allocated_to) }
    it { is_expected.to respond_to(:audit_status) }
    it { is_expected.to respond_to(:document_type) }
    it { is_expected.to respond_to(:organisations) }
    it { is_expected.to respond_to(:page) }
    it { is_expected.to respond_to(:per_page) }
    it { is_expected.to respond_to(:primary_org_only) }
    it { is_expected.to respond_to(:sort) }
    it { is_expected.to respond_to(:sort_direction) }
    it { is_expected.to respond_to(:theme_id) }
    it { is_expected.to respond_to(:title) }
    it { is_expected.to respond_to(:topics) }

    context 'initialized with blank organisations' do
      subject { described_class.new(organisations: '') }

      it { is_expected.to have_attributes(organisations: []) }
    end

    context 'initialized with blank topics' do
      subject { described_class.new(topics: '') }

      it { is_expected.to have_attributes(topics: []) }
    end

    describe '.allocated_policy' do
      subject { described_class.new(allocated_to: allocated_to) }

      context 'allocated to no one' do
        let(:allocated_to) { 'no_one' }

        it {
          is_expected.to have_attributes(allocated_policy: Policies::Unallocated)
        }
      end

      context 'allocated to anyone' do
        let(:allocated_to) { 'anyone' }

        it { is_expected.to have_attributes(allocated_policy: Policies::NoPolicy) }
      end

      context 'allocated to someone' do
        let(:allocated_to) { 'someone' }

        it { is_expected.to have_attributes(allocated_policy: Policies::Allocated) }
      end
    end

    describe '.audited_policy' do
      subject { described_class.new(audit_status: audit_status) }

      context 'audited' do
        let(:audit_status) { :audited }

        it {
          is_expected.to have_attributes(audited_policy: Policies::Audited)
        }
      end

      context 'not audited' do
        let(:audit_status) { :non_audited }

        it { is_expected.to have_attributes(audited_policy: Policies::NonAudited) }
      end

      context 'audit status not available' do
        let(:audit_status) { nil }

        it { is_expected.to have_attributes(audited_policy: Policies::NoPolicy) }
      end
    end

    context 'with allocated to' do
      subject { described_class.new(allocated_to: :double) }

      it { is_expected.to have_attributes(allocated_to: 'double') }
    end

    context 'with audit status' do
      subject { described_class.new(audit_status: 'double') }

      it { is_expected.to have_attributes(audit_status: :double) }
    end

    context 'with sort criteria' do
      subject { described_class.new(sort: 'foo', sort_direction: 'asc') }

      it { is_expected.to have_attributes(sort_by: 'foo_asc') }
    end
  end
end
