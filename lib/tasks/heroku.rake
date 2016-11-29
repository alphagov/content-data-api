namespace :heroku do
  desc 'Configure the environment to do Heroku deployments'
  task :prepare do |_task|
    Kernel.system 'git remote add heroku https://git.heroku.com/content-performance-manager.git'
  end
end
