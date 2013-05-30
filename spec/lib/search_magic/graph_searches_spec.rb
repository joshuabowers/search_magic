require 'spec_helper'

describe SearchMagic::FullTextSearch do
  context "when given two models which search on each other" do
    describe "calculating searchables from the first model" do
      subject { Graph1ModelA }
      it("should not raise an error") { expect { subject.searchables }.to_not raise_error }
      its("searchables.keys") { should include(:foo, :graph_1_model_b_bar) }
      its("searchables.keys") { should_not include(:graph_1_model_b_graph_1_model_a, :graph_1_model_b_graph_1_model_a_foo) }
    end
    
    describe "calculating searchables from the second model" do
      subject { Graph1ModelB }
      it("should not raise an error") { expect { subject.searchables }.to_not raise_error }
      its("searchables.keys") { should include(:bar, :graph_1_model_a_foo) }
      its("searchables.keys") { should_not include(:graph_1_model_a_graph_1_model_b, :graph_1_model_a_graph_1_model_b_bar) }
    end
  end
end