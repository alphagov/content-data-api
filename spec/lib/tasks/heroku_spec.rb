require 'rails_helper'
require 'rake'

RSpec.describe 'Import organisation rake task' do
  describe 'heroku:prepare' do
    before do
      Rake::Task['heroku:prepare'].reenable
    end

    it 'adds the remote repo for Heroku' do
      prepare_command = 'git remote add heroku https://git.heroku.com/content-performance-manager.git'
      expect(Kernel).to receive(:system).with(prepare_command)

      Rake::Task['heroku:prepare'].invoke
    end
  end

  describe 'heroku:deploy' do
    before do
      Rake::Task['heroku:deploy'].reenable
    end

    it 'deploys the application to Heroku' do
      prepare_command = 'git push heroku master'
      expect(Kernel).to receive(:system).with(prepare_command)

      Rake::Task['heroku:deploy'].invoke
    end
  end
end
