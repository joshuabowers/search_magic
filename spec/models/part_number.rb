class PartNumber
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field value
  
  references_many :parts
  referenced_in :part_category
  
  search_on :value
end