RSpec.shared_examples 'a materialized view' do |table_name|
  it 'refresh the materialized view' do
    expect(Scenic.database).to receive(:refresh_materialized_view).with(table_name, concurrently: true, cascade: false)

    subject.refresh
  end

  it 'prepares the environment to refresh the view' do
    allow(Scenic.database).to receive(:refresh_materialized_view)
    expect(Aggregations::MaterializedView).to receive(:prepare)

    subject.refresh
  end
end
