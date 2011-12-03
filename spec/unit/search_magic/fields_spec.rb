require 'spec_helper'

describe SearchMagic::FullTextSearch do
  context "when included in a model without :searchables" do
    subject { NoSearchables }
    
    it { should respond_to(:search_on).with(2).arguments }
    
    it { should respond_to(:searchable_fields) }
    its(:searchable_fields) { should be_a(Hash) }  
    its(:searchable_fields) { should be_blank }
    
    its("fields.keys") { should include("searchable_values") }
    describe "searchable_values" do
      subject { NoSearchables.fields["searchable_values"] }
      its(:type) { should == Array }
      its(:default) { should == [] }
    end
    
    it { should respond_to(:search_for).with(1).argument }
    it { should respond_to(:and_for).with(1).argument }
  end
  
  context "when :search_on called with [:title, :description, :tags]" do
    subject { Asset }
    its("searchable_fields.keys") { should include(:title, :description, :tags) }
    its("searchable_fields.keys") { should_not include(:uuid) }
    
    its("searchables.keys") { should include(:title, :description, :tag) }
    its("searchables.keys") { should_not include(:uuid) }
  end
  
  describe "saving a model should run the :update_searchable_values callback" do
    subject { Asset.new }
    after(:each) { subject.save }
    it { subject.should_receive :update_searchable_values }
  end
  
  context "when a model is saved, its :searchable_values update" do
    subject { Fabricate.build(:asset, :title => "Foo Bar: The Bazzening", :description => "Sequel to last years hit summer blockbuster.", :tags => ["movies", "foo.bar", "the-bazzening"]) }
    before(:each) { subject.save }
    its(:searchable_values) { should_not be_empty }
    its(:searchable_values) { should include("title:foo", "title:bar", "title:the", "title:bazzening")}
    its(:searchable_values) { should include("description:sequel", "description:to", "description:last", "description:years", "description:hit", "description:summer", "description:blockbuster")}
    its(:searchable_values) { should_not include("uuid:ae9d14ee-be93-11df-9fec-78ca39fffe11", "uuid:ae9d14ee")}
    its(:searchable_values) { should include("tag:movies", "tag:foo.bar", "tag:the-bazzening")}
  end
    
  context "when :search is performed on a model without :searchables" do
    subject { NoSearchables.search_for("foo") }
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
      subject { Asset.search_for(nil) }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should_not include(:searchable_values) }
    end
    
    context "when searching on an empty string" do
      subject { Asset.search_for("") }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should_not include(:searchable_values) }
    end
    
    context "when searching for anything" do
      subject { Asset.search_for("foo") }
      it { should be_a(Mongoid::Criteria) }
      its("selector.keys") { should include(:searchable_values) }
    end
    
    context "when searching for 'foo'" do
      subject { Asset.search_for("foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Foo Bar: The Bazzening", "Undercover Foo") }
    end
    
    context "when searching for 'title:foo'" do
      subject { Asset.search_for("title:foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Foo Bar: The Bazzening", "Undercover Foo") }
    end
    
    context "when searching for 'description:bazzening'" do
      subject { Asset.search_for("description:bazzening") }
      its(:count) { should == 0 }
    end
    
    context "when searching for 'tag:foo.bar'" do
      subject { Asset.search_for("tag:foo.bar").map(&:title) }
      its(:count) { should == 1 }
      its(:first) { should == "Foo Bar: The Bazzening" }
    end
    
    context "when searching for 'tag:movies cheese" do
      subject { Asset.search_for("tag:movies cheese").map(&:title) }
      its(:count) { should == 1 }
      its(:first) { should == "Cheese of the Damned" }
    end
    
    context "when chaining a search for 'foo' off of :all" do
      subject { Asset.all.search_for("foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Foo Bar: The Bazzening", "Undercover Foo") }
    end

    context "when chaining a search for 'foo' off of a search for 'bar'" do
      subject { Asset.search_for("bar").search_for("foo").map(&:title) }
      its(:count) { should == 1 }
      it { should == ["Foo Bar: The Bazzening"] }
    end
    
    context "when chaining a search for 'foo' off of a search for 'bar' using :and_for" do
      subject { Asset.search_for("bar").and_for("foo").map(&:title) }
      its(:count) { should == 1 }
      it { should == ["Foo Bar: The Bazzening"] }
    end
    
    context "when chaining a search for 'foo' off of :arrange" do
      subject { Asset.arrange(:title, :desc).search_for("foo").map(&:title) }
      its(:count) { should == 2 }
      it { should include("Undercover Foo", "Foo Bar: The Bazzening") }
    end
  end
  
  context "when working with a model with :skip_prefix on a field" do
    subject { FieldSkipPrefix }
    its('searchable_fields.keys') { should include(:name) }
    its('searchables.keys') { should include(:"") }
  end
  
  context "when searching for a model with :skip_prefix on a field" do
    before(:each) do
      5.times { Fabricate(:field_skip_prefix) }
    end
    
    let(:dirigible) { Fabricate(:field_skip_prefix, :name => "Dirigible") }
    
    context "the field should not be prefixed in :searchable_values" do
      subject { dirigible }
      its(:searchable_values) { should include("dirigible") }
      its(:searchable_values) { should_not include("name:dirigible") }
      its(:searchable_values) { should_not include(":dirigible") }
    end
    
    context "searching on that field should return nothing" do
      subject { FieldSkipPrefix.search_for("name:test") }
      its(:count) { should == 0 }
    end
    
    context "performing a full text search should return instances" do
      subject { FieldSkipPrefix.search_for("test") }
      its(:count) { should == 5 }
    end
  end
end