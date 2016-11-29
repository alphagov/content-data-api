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
end
