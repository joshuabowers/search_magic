class Part
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :serial
  field :status
  field :category
  
  referenced_in :person
  
  search_on :serial
  search_on :status
end