module SearchMagic
  require 'chronic'
  require 'search_magic/breadcrumb'
  require 'search_magic/stack_frame'
  require 'search_magic/metadata'
  require 'search_magic/full_text_search'
  require 'search_magic/railtie' if defined?(Rails)
  include ActiveSupport::Configurable
  extend ActiveSupport::Concern
  
  included do
    include FullTextSearch
  end
end
