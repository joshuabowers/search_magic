class Part
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :serial
  field :status
  
  searchable_fields :serial, :status
end