require 'spec_helper'

describe SearchMagic do
  context "when included in a model" do
    subject { SimpleInclusionModel }
    it { should respond_to(:search_on, :search_for, :searchables, :arrange) }
    its("searchables.keys") { should include(:foo, :bar) }
  end
  
  context "when saving a model" do
    subject { Fabricate.build(:simple_inclusion_model, :foo => "F.o-o") }
    before(:each) { subject.save! }
    its(:searchable_values) { should include("foo:f.o-o") }
    its(:arrangeable_values) { should include(:foo => "F.o-o") }
  end
  
  context "when searching for a model" do
    before(:each) { Fabricate(:simple_inclusion_model) }
    subject { SimpleInclusionModel.search_for("foo") }
    its(:count) { should == 1 }
    its("first.foo") { should == "a foo" }
    its("first.bar") { should == "a bar" }
  end
end