class Developer
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  field :opened_on, :type => Date
  has_many :games
  
  search_on :name
  search_on :opened_on
  search_on :games
end