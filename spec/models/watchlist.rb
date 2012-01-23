class Watchlist
  include Mongoid::Document
  include SearchMagic
  field :description
  
  embedded_in :user
  search_on :description
end