class PartCategory
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  
  has_many :part_numbers
  
  search_on :name
end