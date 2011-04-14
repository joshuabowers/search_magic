class SimpleInclusionModel
  include Mongoid::Document
  include SearchMagic
  field :foo
  field :bar
  search_on :foo, :keep_punctuation => true
  search_on :bar
end