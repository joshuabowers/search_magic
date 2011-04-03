class IsSearchable
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :bar, :type => String
  references_many :absolutely_not_searchables
  
  search_on :bar
end