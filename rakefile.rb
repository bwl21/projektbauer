require 'rspec/core/rake_task'
require 'rake/clean'

RSpec::Core::RakeTask.new(:spec)

CLEAN << "spec/tmp_output"

task :default do
 sh "rake -T"
end