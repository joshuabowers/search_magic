require 'rubygems'
require 'bundler/setup'

require 'mongoid'
require 'search_magic'
require 'fabrication'

MODELS = File.join(File.dirname(__FILE__), "models")

Mongoid.configure do |config|
  config.connect_to("search_magic_test")
end

Dir[ File.join(MODELS, "*.rb") ].sort.each {|file| require file}

RSpec::configure do |config|
  config.mock_with :rspec
  
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end