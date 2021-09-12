require 'simplecov'
require 'shoulda'
require 'simplecov-lcov'


SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.single_report_path = File.expand_path(File.dirname(__FILE__) + '/../coverage/lcov.info')
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::LcovFormatter,
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  root File.expand_path(File.dirname(__FILE__) + '/..')
  add_filter "/test/"
end

# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

fixtures = []
Dir.chdir(File.dirname(__FILE__) + '/fixtures/') do
  fixtures = Dir.glob('*.yml').map{|s| s.gsub(/.yml$/, '')}
end
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fixtures)

# Ensure that we are using the temporary fixture path
#Engines::Testing.set_fixture_path
