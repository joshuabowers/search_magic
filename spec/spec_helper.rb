require 'rubygems'
require 'bundler/setup'

require 'mongoid'
require 'search_magic'

MODELS = File.join(File.dirname(__FILE__), "models")

Mongoid.configure do |config|
  name = "search_magic_test"
  config.master = Mongo::Connection.new.db(name)
  config.logger = nil
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