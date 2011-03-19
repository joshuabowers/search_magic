class Person
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  embeds_one :address
  embeds_many :phones
  references_many :parts
  
  accepts_nested_attributes_for :address, :phones
  
  search_on :name
  search_on :address
  search_on :phones, :as => :mobile, :only => [:number]
  search_on :parts, :except => :status
end