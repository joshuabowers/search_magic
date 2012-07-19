class Graph1ModelB
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :bar
  has_and_belongs_to_many :graph_1_model_as
  search_on :bar
  search_on :graph_1_model_as
end