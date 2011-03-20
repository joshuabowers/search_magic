class PartNumber
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :value
  
  references_many :parts
  referenced_in :part_category
  
  search_on :value, :as => :part_number
  search_on :part_category, :as => :category
end