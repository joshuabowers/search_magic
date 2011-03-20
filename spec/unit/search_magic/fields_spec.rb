require 'spec_helper'

describe SearchMagic::FullTextSearch do
  context "when included in a model without :searchables" do
    subject { NoSearchables }
    
    it { should respond_to(:search_on).with(2).arguments }
    
    it { should respond_to(:searchable_fields) }
    its(:searchable_fields) { should be_a(Hash) }  
    its(:searchable_fields) { should be_blank }
    
    its("fields.keys") { should include("_searchable_values") }
    describe "_searchable_values" do
      subject { NoSearchables.fields["_searchable_values"] }
      its(:type) { should == Array }
      its(:default) { should == [] }
    end
    
    it { should respond_to(:search).with(1).argument }
  end
  
  context "when :search_on called with [:title, :description, :tags]" do
    subject { Asset }
    its("searchable_fields.keys") { should include(:title, :description, :tags) }
    its("searchable_fields.keys") { should_not include(:uuid) }
    
    its(:searchables) { should include(:title, :description, :tag) }
    its(:searchables) { should_not include(:uuid) }
  end
  
  describe "saving a model should run the :update_searchable_values callback" do
    subject { Asset.new }
    after(:each) { subject.save }
    it { subject.should_receive :update_searchable_values }
  end
  
  context "when a model is saved, its :_searchable_values update" do
    subject { Asset.new(:title => "Foo Bar: The Bazzening", :description => "Sequel to last years hit summer blockbuster.", :tags => ["movies", "foo.bar", "the-bazzening"], :uuid => "ae9d14ee-be93-11df-9fec-78ca39fffe11")}
    before(:each) { subject.save }
    its(:_searchable_values) { should_not be_empty }
    its(:_searchable_values) { should include("title:foo", "title:bar", "title:the", "title:bazzening")}
    its(:_searchable_values) { should include("description:sequel", "description:to", "description:last", "description:years", "description:hit", "description:summer", "description:blockbuster")}
    its(:_searchable_values) { should_not include("uuid:ae9d14ee-be93-11df-9fec-78ca39fffe11", "uuid:ae9d14ee")}
    its(:_searchable_values) { should include("tag:movies", "tag:foo.bar", "tag:the-bazzening")}
  end
  
  context "when :search is performed on a model without :searchables" do
    subject { NoSearchables.search("foo") }
    it { should be_a(Mongoid::Criteria) }
    its(:count) { should == 0 }
  end
  
  context "when :search is performed on a model with :searchables" do
    before(:each) do
      Asset.create(:title => "Foo Bar: The Bazzening", :description => "Sequel to last years hit summer blockbuster.", :tags => ["movies", "foo.bar", "the-bazzening"])
      Asset.create(:title => "Undercover Foo", :description => "When a foo goes undercover, how far will he go to protect those he loves?", :tags => ["undercover.foo", "action"])
      Asset.create(:title => "Cheese of the Damned", :description => "This is not your father's munster.", :tags => ["movies", "cheese", "munster", "horror"])
    end

    context "when searching for nil" do
      subject { Asset.search(nil) }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should_not include(:_searchable_values) }
    end
    
    context "when searching on an empty string" do
      subject { Asset.search("") }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should_not include(:_searchable_values) }
    end
    
    context "when searching for anything" do
      subject { Asset.search("foo") }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should include(:_searchable_values) }
    end
    
    context "when searching for 'foo'" do
      subject { Asset.search("foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Foo Bar: The Bazzening", "Undercover Foo") }
    end
    
    context "when searching for 'title:foo'" do
      subject { Asset.search("title:foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Foo Bar: The Bazzening", "Undercover Foo") }
    end
    
    context "when searching for 'description:bazzening'" do
      subject { Asset.search("description:bazzening") }
      its(:count) { should == 0 }
    end
    
    context "when searching for 'tag:foo.bar'" do
      subject { Asset.search("tag:foo.bar").map(&:title) }
      its(:count) { should == 1 }
      its(:first) { should == "Foo Bar: The Bazzening" }
    end
    
    context "when searching for 'tag:movies cheese" do
      subject { Asset.search("tag:movies cheese").map(&:title) }
      its(:count) { should == 1 }
      its(:first) { should == "Cheese of the Damned" }
    end
  end
end