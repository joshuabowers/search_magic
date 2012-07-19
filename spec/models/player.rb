class Player
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  has_and_belongs_to_many :games
  
  search_on :name
  search_on :games, :only => [:title, :developer]
end