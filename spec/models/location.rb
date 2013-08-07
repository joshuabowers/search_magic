class Location
  include Mongoid::Document
  include SearchMagic
  field :keywords, type: Array
  embedded_in :program
  search_on :keywords
end