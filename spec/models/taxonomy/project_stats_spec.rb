RSpec.describe Taxonomy::ProjectStats do
  let(:project) { create(:taxonomy_project, name: 'A Fancy Group') }

  describe '#todo_count' do
    it 'returns the total number of todos' do
      create(:taxonomy_todo, taxonomy_project: project)
      create(:taxonomy_todo, taxonomy_project: project)

      stats = Taxonomy::ProjectStats.new(project)

      expect(stats.todo_count).to eql(2)
    end
  end

  describe '#done_count' do
    it 'returns the number of done todos' do
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project)

      stats = Taxonomy::ProjectStats.new(project)

      expect(stats.done_count).to eql(2)
    end
  end

  describe '#still_todo_count' do
    it 'returns the number of todos still to do' do
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project)

      stats = Taxonomy::ProjectStats.new(project)

      expect(stats.still_todo_count).to eql(1)
    end
  end

  describe '#progress_percentage' do
    it 'returns percentage of todos done' do
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project, completed_at: Time.now)
      create(:taxonomy_todo, taxonomy_project: project)

      stats = Taxonomy::ProjectStats.new(project)

      expect(stats.progress_percentage).to eql(75.0)
    end
  end
end
