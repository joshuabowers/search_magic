module SearchMagic
  # require 'active_support/concern'
  # require 'active_support/configurable'
  require 'mongoid'
  include ActiveSupport::Configurable
  extend ActiveSupport::Concern
  require 'chronic'
  require 'search_magic/configuration'
  require 'search_magic/breadcrumb'
  require 'search_magic/stack_frame'
  require 'search_magic/metadata'
  require 'search_magic/searchable_value'
  require 'search_magic/full_text_search'
  require 'search_magic/railtie' if defined?(Rails)
  
  included do
    include FullTextSearch
  end
end
