class User
  include Mongoid::Document
  # include SearchMagic
  field :name
  
  embeds_many :watchlists
end