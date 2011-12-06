require 'spec_helper'

describe SearchMagic do
  context "documents should have a method for finding values matching a pattern" do
    let(:asset) { Fabricate(:asset) }
    subject { asset }
    it { should respond_to(:values_matching).with(1).argument }
  end
  
  context "given a pattern, :values_matching should return an array" do
    let(:asset) { Fabricate(:asset) }
    subject { asset.values_matching("some pattern") }
    it { should be_an(Array) }
  end
  
  context "given a pattern" do
    before(:each) { Fabricate(:asset, :tags => %w{b.a.r p'zow}) }
    let(:asset) { Asset.first }
    let(:pattern) { "asset generic tag:p'zow" }
    context "which matches the document" do
      subject { Asset.search_for(pattern) }
      its(:count) { should == 1 }
      its(:first) { should == asset }
    end
    context ":values_matching" do
      subject { asset.values_matching(pattern) }
      its(:length) { should == 3 }
      it { should include("title:asset", "description:generic", "tag:p'zow") }
      it { should_not include("title:title", "description:description", "tag:b.a.r") }
    end
  end
end