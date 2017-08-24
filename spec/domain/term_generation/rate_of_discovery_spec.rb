require 'ostruct'

RSpec.describe TermGeneration::RateOfDiscovery do
  subject { described_class }

  describe ".calculate" do
    let(:result) { subject.calculate(project) }
    let(:project) { double }

    let(:project_todos) do
      (0..9).map do |i|
        OpenStruct.new(terms: (0..i).to_a.map(&:to_s))
      end
    end

    before do
      allow(subject)
        .to receive(:project_todos)
        .with(project)
        .and_return(project_todos)
    end

    it "performs the calculation" do
      expect(result).to eql Array.new(10) { 1.0 }
    end
  end
end
