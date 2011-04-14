require 'spec_helper'

describe SearchMagic::Breadcrumb do
  context "when creating a breadcrumb without any options" do
    subject { SearchMagic::Breadcrumb.new(:a_field, {}) }
    its(:options) { should_not be_blank }
    its(:options) { should include(:only => [], :except => []) }
    its(:field_name) { should == :a_field }
    its(:term) { should == :a_field }
  end
  
  context "when creating a breadcrumb with the :skip_prefix option" do
    subject { SearchMagic::Breadcrumb.new(:a_field, :skip_prefix => true) }
    its(:field_name) { should == :a_field }
    its(:term) { should be_nil }
  end
  
  context "when creating a breadcrumb with the :as option" do
    subject { SearchMagic::Breadcrumb.new(:a_field, :as => :something_completely_different) }
    its(:field_name) { should == :a_field }
    its(:term) { should == :something_completely_different }
  end
  
  context "when creating a breadcrumb with an array for the :only and :except options" do
    subject { SearchMagic::Breadcrumb.new(:a_collection, :only => [:foo, :bar], :except => [:baz]) }
    its(:options) { should include(:only => [:foo, :bar], :except => [:baz]) }
  end
  
  context "when creating a breadcrumb with a singular value for the :only and :except options" do
    subject { SearchMagic::Breadcrumb.new(:a_collection, :only => :foo, :except => :bar) }
    its(:options) { should include(:only => [:foo], :except => [:bar]) }
  end
end