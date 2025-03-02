# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :test

task test: %i[rubocop spec]

desc 'Run RuboCop'
task :rubocop do
  sh 'rubocop'
end
