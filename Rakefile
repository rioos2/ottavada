require_relative 'init'
require_relative 'lib/support/tasks_helper'
require_relative 'lib/local_repository'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  # no rspec available
end

unless ENV['CI'] || Rake.application.top_level_tasks.include?('default') || LocalRepository.ready?
  abort('Please use the master branch and make sure you are up to date.'.colorize(:red))
end

desc "Create release"
task :release, [:version] do |_t, args|
  version = get_version(args)

    $stdout.puts 'Rio/OS release'.colorize(:blue)
    Release::RioosRelease.new(version).execute
    Slack::TagNotification.release(version) unless dry_run?
end