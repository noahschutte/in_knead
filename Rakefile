# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require "rake/testtask"

Rails.application.load_tasks

task :server do
  exec "rackup -p 3000"
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
