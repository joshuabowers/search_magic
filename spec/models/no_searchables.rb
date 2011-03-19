class NoSearchables
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :foo
end