require 'search_magic'
require 'rails'
module SearchMagic
  class Railtie < Rails::Railtie
    railtie_name :search_magic
    
    rake_tasks do
      Dir["tasks/**/*.rake"].each { |ext| load ext }
    end
  end
end