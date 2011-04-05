class Graph1ModelB
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :bar
  references_and_referenced_in_many :graph_1_model_as
  search_on :bar
  search_on :graph_1_model_as
end