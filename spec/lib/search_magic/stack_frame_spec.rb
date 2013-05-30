require 'spec_helper'

describe SearchMagic::StackFrame do
  context "when constructing a StackFrame from a target type" do
    subject { SearchMagic::StackFrame.from_type(Fixnum) }
    its(:origin_type) { should == nil }
    its(:target_type) { should == Fixnum }
    its(:association) { should == nil }
    its(:path) { should == [] }
    its(:token) { should == [nil, nil, Fixnum] }
    its(:inverse_token) { should == [Fixnum, nil, nil] }
  end
  
  context "when constructing a StackFrame with an association" do
    subject { SearchMagic::StackFrame.new(Game, Game.reflect_on_association(:players)) }
    its(:origin_type) { should == Game }
    its(:target_type) { should == Player }
    its(:association) { should be_a Mongoid::Relations::Metadata }
    its(:path) { should be_an Array }
    its(:token) { should == [Game, :players, Player] }
    its(:inverse_token) { should == [Player, :games, Game] }
  end
  
  context "when looking at a stack frame with breadcrumbs containing no exceptions" do
    subject { SearchMagic::StackFrame.new(Object, nil, [SearchMagic::Breadcrumb.new(:a_collection, {})]) }
    it { subject.wants_field?(:foo).should be_true }
    it { subject.wants_field?(:bar).should be_true }
  end
  
  context "when looking at a stack frame with the current breadcrumb containing an only" do
    subject { SearchMagic::StackFrame.new(Object, nil, [SearchMagic::Breadcrumb.new(:a_collection, {:only => :foo})]) }
    it { subject.wants_field?(:foo).should be_true }
    it { subject.wants_field?(:bar).should be_false }
  end

  context "when looking at a stack frame with the current breadcrumb containing an except" do
    subject { SearchMagic::StackFrame.new(Object, nil, [SearchMagic::Breadcrumb.new(:a_collection, {:except => :foo})]) }
    it { subject.wants_field?(:foo).should be_false }
    it { subject.wants_field?(:bar).should be_true }
  end
  
  context "when looking at a stack frame with the current breadcrumb having overlapping only and except" do
    subject { SearchMagic::StackFrame.new(Object, nil, [SearchMagic::Breadcrumb.new(:a_collection, {:except => :foo, :only => [:foo, :bar, :baz]})]) }
    it { subject.wants_field?(:foo).should be_false }
    it { subject.wants_field?(:bar).should be_true }
    it { subject.wants_field?(:baz).should be_true }
  end
end