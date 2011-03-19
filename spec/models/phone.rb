class Phone
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :country_code, :type => Integer, :default => 1
  field :number
  embedded_in :person
  
  search_on :country_code
  search_on :number
end