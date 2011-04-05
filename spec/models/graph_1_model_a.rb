class Graph1ModelA
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :foo
  references_and_referenced_in_many :graph_1_model_bs
  search_on :foo
  search_on :graph_1_model_bs
end