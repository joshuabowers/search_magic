class Program
  include Mongoid::Document
  include SearchMagic
  embedded_in :orgranization
  embeds_many :locations
  search_on :locations
end