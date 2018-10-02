RSpec.describe Reports::FindEditionMetrics do
  include ItemSetupHelpers

  it "returns editions metrics filtered by specified metrics" do
    today = Date.today

    create_metric(base_path: '/base_path', date: today, edition: { word_count: 10_000, number_of_pdfs: 3 })

    metrics = described_class.run('/base_path', %w[word_count])

    expect(metrics).to match_array([{
      name: 'word_count',
      value: 10_000
    }])
  end

  it "returns editions metrics for latest edition" do
    today = Date.today
    tomorrow = today + 1
    create_metric(base_path: '/base_path', date: today, edition: { word_count: 10_000, number_of_pdfs: 3 })
    create_metric(base_path: '/base_path', date: tomorrow, edition: { word_count: 20_000, number_of_pdfs: 5 })

    metrics = described_class.run('/base_path', %w[word_count number_of_pdfs])

    expect(metrics).to match_array([
      { name: 'word_count', value: 20_000 },
      { name: 'number_of_pdfs', value: 5 },
    ])
  end
end
