require 'rails_helper'
require 'rake'

RSpec.describe 'Import organisation rake task' do
  describe 'heroku:prepare' do
    subject { Rake::Task['heroku:prepare'] }

    before { subject.reenable }

    it 'adds the remote repo for Heroku' do
      command = 'git remote add heroku https://git.heroku.com/content-performance-manager.git'
      expect(Kernel).to receive(:system).with(command)

      subject.invoke
    end
  end

  describe 'heroku:deploy' do
    subject { Rake::Task['heroku:deploy'] }

    before { subject.reenable }

    it 'deploys the application to Heroku' do
      command = 'git push heroku master'
      expect(Kernel).to receive(:system).with(command)

      subject.invoke
    end
  end

  describe 'heroku:db:migrate' do
    subject { Rake::Task['heroku:db:migrate'] }

    before { subject.reenable }

    it 'run pending migrations in Heroku' do
      command = 'heroku rake db:migrate'
      expect(Kernel).to receive(:system).with(command)

      subject.invoke
    end
  end
end
