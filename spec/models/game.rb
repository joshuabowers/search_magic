class Game
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :title, :type => String
  field :price, :type => Float
  field :high_score, :type => Integer
  field :released_on, :type => Date
  has_and_belongs_to_many :players
  belongs_to :developer
  
  search_on :title
  search_on :price, :keep_punctuation => true
  search_on :high_score
  search_on :released_on, :keep_punctuation => true
  search_on :developer, :except => :opened_on
  search_on :players
end