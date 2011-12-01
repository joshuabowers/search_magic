class FieldSkipPrefix
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name, :type => String
  
  search_on :name, :skip_prefix => true
end