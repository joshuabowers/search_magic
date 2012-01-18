module SearchMagic
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir["tasks/**/*.rake"].each { |ext| load ext }
    end
  end
end