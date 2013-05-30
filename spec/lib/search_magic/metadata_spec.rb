require 'spec_helper'

describe SearchMagic::Metadata do
  context "when dealing with a single breadcrumb" do
    subject { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {})]) }
    its(:name) { should == :foo }
  end
  
  context "when dealing with breadcrumbs without options" do
    subject { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {}), SearchMagic::Breadcrumb.new(:bar, {}), SearchMagic::Breadcrumb.new(:baz, {})]) }
    its(:name) { should == :foo_bar_baz }
  end
  
  context "when dealing with breadcrumbs with :skip_prefix" do
    subject { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {:skip_prefix => true}), SearchMagic::Breadcrumb.new(:bar, {})]) }
    its(:name) { should == :bar }
  end
  
  context "when dealing with breadcrumbs with :skip_prefix and :as options" do
    subject { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {}), SearchMagic::Breadcrumb.new(:bar, {:skip_prefix => true}), SearchMagic::Breadcrumb.new(:baz, {:as => :qux})]) }
    its(:name) { should == :foo_qux }
  end
  
  context "when dealing with a nil instance for a given breadcrump" do
    let(:metadata) { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {}), SearchMagic::Breadcrumb.new(:bar, {})], :options => {}) }
    let(:instance) { Struct.new(:foo).new(nil) }
    it { expect { metadata.searchable_value_for(instance) }.to_not raise_error }
    it { metadata.searchable_value_for(instance).should be_blank }
  end
end