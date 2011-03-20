class Part
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :serial
  field :status
  
  referenced_in :part_number
  
  search_on :serial
  search_on :status
  search_on :part_number, :skip_prefix => true
end