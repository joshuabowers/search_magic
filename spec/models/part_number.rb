class PartNumber
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :value
  
  has_many :parts
  belongs_to :part_category
  
  search_on :value, :as => :part_number
  search_on :part_category, :as => :category
end