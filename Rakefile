require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'

Dir["tasks/*"].each { |t| load t }

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  #t.verbose = true
end

desc "Generate instructions and solution from markdown in doc/"
task :instructions do
  PeopleAgainstSecurity::Pandoc.run!(File.expand_path("../doc", __FILE__))
end
