class Player
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  references_and_referenced_in_many :games
  
  search_on :name
  search_on :games, :only => [:title, :developer]
end