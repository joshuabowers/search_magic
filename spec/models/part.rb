class Part
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :serial
  field :status
  field :category
  
  searchable_field :serial
  searchable_field :status
end