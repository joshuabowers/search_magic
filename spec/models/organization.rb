class Organization
  include Mongoid::Document
  include SearchMagic
  embeds_many :programs
  search_on :programs
end