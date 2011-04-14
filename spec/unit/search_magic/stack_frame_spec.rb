require 'spec_helper'

describe SearchMagic::StackFrame do
  context "when looking at a stack frame with breadcrumbs containing no exceptions" do
    subject { SearchMagic::StackFrame.new(Object, [SearchMagic::Breadcrumb.new(:a_collection, {})]) }
    it { subject.wants_field?(:foo).should be_true }
    it { subject.wants_field?(:bar).should be_true }
  end
  
  context "when looking at a stack frame with the current breadcrumb containing an only" do
    subject { SearchMagic::StackFrame.new(Object, [SearchMagic::Breadcrumb.new(:a_collection, {:only => :foo})]) }
    it { subject.wants_field?(:foo).should be_true }
    it { subject.wants_field?(:bar).should be_false }
  end

  context "when looking at a stack frame with the current breadcrumb containing an except" do
    subject { SearchMagic::StackFrame.new(Object, [SearchMagic::Breadcrumb.new(:a_collection, {:except => :foo})]) }
    it { subject.wants_field?(:foo).should be_false }
    it { subject.wants_field?(:bar).should be_true }
  end
  
  context "when looking at a stack frame with the current breadcrumb having overlapping only and except" do
    subject { SearchMagic::StackFrame.new(Object, [SearchMagic::Breadcrumb.new(:a_collection, {:except => :foo, :only => [:foo, :bar, :baz]})]) }
    it { subject.wants_field?(:foo).should be_false }
    it { subject.wants_field?(:bar).should be_true }
    it { subject.wants_field?(:baz).should be_true }
  end
end