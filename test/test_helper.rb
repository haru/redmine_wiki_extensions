require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
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
