class Asset
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :title
  field :description
  field :tags, :type => Array, :default => []
  field :uuid
  
  search_on :title
  search_on :description
  search_on :tags, :keep_punctuation => true
end