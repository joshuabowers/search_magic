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
  
  context "when dealing with breadcrumbs with :skip_prefix and :as options" do
    subject { SearchMagic::Metadata.new(:through => [SearchMagic::Breadcrumb.new(:foo, {}), SearchMagic::Breadcrumb.new(:bar, {:skip_prefix => true}), SearchMagic::Breadcrumb.new(:baz, {:as => :qux})]) }
    its(:name) { should == :foo_qux }
  end
end