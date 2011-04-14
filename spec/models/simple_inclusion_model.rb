class SimpleInclusionModel
  include Mongoid::Document
  include SearchMagic
  field :foo
  field :bar
  search_on :foo
  search_on :bar
end