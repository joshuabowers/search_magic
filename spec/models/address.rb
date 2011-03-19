class Address
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :street
  field :city
  field :state
  field :post_code
  embedded_in :person
  
  search_on :street
  search_on :city
  search_on :state
  search_on :post_code  
end