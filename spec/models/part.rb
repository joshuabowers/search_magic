class Part
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :serial
  field :status
  field :category
  
  referenced_in :person
  referenced_in :part_number
  
  search_on :serial
  search_on :status
  search_on :part_category, :as => :category, :through => :part_number
end