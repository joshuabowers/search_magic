class User
  include Mongoid::Document
  field :name
  
  embeds_many :watchlists
end