class PartCategory
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  
  references_many :part_numbers
  
  search_on :name
end