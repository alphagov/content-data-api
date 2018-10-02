RSpec.describe Reports::FindEditionMetrics do

  context 'multiple editions' do
    before do
      edition = create :edition, 
        base_path: '/base_path', 
        date: '2018-01-01',
        facts: {
          'words': 10_000,
          'pdf_count': 3
        }
    end

    it "returns editions metrics filtered by specified metrics" do
      metrics = described_class.run('/base_path', %w[words])

      expect(metrics).to match_array([{
        name: 'words',
        value: 10_000
      }])
    end

    it "returns editions metrics for latest edition" do
      create :edition, 
        base_path: '/base_path', 
        date: '2018-02-01',
        facts: {
          'words': 20_000,
          'pdf_count': 5
        }

      metrics = described_class.run('/base_path', %w[words pdf_count])

      expect(metrics).to match_array([
        { name: 'words', value: 20_000 },
        { name: 'pdf_count', value: 5 },
      ])
    end
  end
end
