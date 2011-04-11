require 'spec_helper'

describe SearchMagic::FullTextSearch do
  context "when included in a model without :searchables" do
    subject { NoSearchables }
    its("fields.keys") { should include("arrangeable_values") }
    describe "arrangeable_values" do
      subject { NoSearchables.fields["arrangeable_values"] }
      its(:type) { should == Hash }
      its(:default) { should == {} }
    end
    
    it { should respond_to(:arrange).with(2).argument }
  end
  
  describe "saving a model should run the :update_arrangeable_values callback" do
    subject { Asset.new }
    after(:each) { subject.save }
    it { subject.should_receive :update_arrangeable_values }
  end
  
  context "when a model is saved, its :arrangeable_values update" do
    subject { Asset.new(:title => "Foo Bar: The Bazzening", :description => "Sequel to last years hit summer blockbuster.", :tags => ["movies", "foo.bar", "the-bazzening"], :uuid => "ae9d14ee-be93-11df-9fec-78ca39fffe11")}
    before(:each) { subject.save }
    its(:arrangeable_values) { should_not be_empty }
    its(:arrangeable_values) { should include(:title => "Foo Bar: The Bazzening") }
    its(:arrangeable_values) { should include(:description => "Sequel to last years hit summer blockbuster.", ) }
    its(:arrangeable_values) { should include(:tag => ["movies", "foo.bar", "the-bazzening"]) }
    its("arrangeable_values.keys") { should_not include(:uuid) }
  end
  
  context "when saving a model with custom method arrangeables which yeild dates" do
    subject { CustomMethodSearchable.new }
    its("class.searchables.keys") { should_not be_empty }
    its("class.searchables.keys") { should include(:random_value, :date_value)}
    it { expect { subject.save }.not_to raise_error }
  end
  
  context "when saving a model with custom method arrangeables" do
    subject { CustomMethodSearchable.new }
    before(:each) { subject.save }
    its(:arrangeable_values) { should_not be_empty }
    its("arrangeable_values.keys") { should include(:random_value, :date_value)}
  end
  
  context "when :arrange is performed on a model with :searchables" do
    before(:each) do
      Asset.create(:title => "Foo Bar: The Bazzening", :description => "Sequel to last years hit summer blockbuster.", :tags => ["movies", "suspense", "foo.bar", "the-bazzening"])
      Asset.create(:title => "Undercover Foo", :description => "When a foo goes undercover, how far will he go to protect those he loves?", :tags => ["movies", "action", "undercover.foo"])
      Asset.create(:title => "Cheese of the Damned", :description => "This is not your father's munster.", :tags => ["movies", "horror", "cheese", "munster"])
    end
    
    context "when arranging a model by nil" do
      subject { Asset.arrange(nil) }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should be_empty }
      its("options.keys") { should_not include(:sort) }
    end
    
    context "when arranging a model by ''" do
      subject { Asset.arrange("") }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should be_empty }
      its("options.keys") { should_not include(:sort) }
    end
    
    context "when arranging a model by a non searchable" do
      subject { Asset.arrange(:is_not_searchable) }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should be_empty }
      its("options.keys") { should_not include(:sort) }
    end
    
    context "when arranging a model by a searchable" do
      subject { Asset.arrange(:title) }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should_not be_empty }
      its(:options) { should include(:sort => [["arrangeable_values.title", :asc]]) }
    end
    
    context "when arranging a model by a searchable.to_s" do
      subject { Asset.arrange("title") }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should_not be_empty }
      its(:options) { should include(:sort => [["arrangeable_values.title", :asc]]) }
    end
    
    context "when arranging a model on multiple searchables" do
      subject { Asset.arrange(:title).arrange(:tag) }
      it { should be_a(Mongoid::Criteria) }
      its(:options) { should include(:sort => [["arrangeable_values.title", :asc], ["arrangeable_values.tag", :asc]]) }
    end
    
    shared_examples_for "arranged assets" do |arrangeable, direction, expected_order|
      context "when arranging a model by '#{arrangeable}' => '#{direction || 'nil'}'" do
        subject { (direction.present? ? Asset.arrange(arrangeable, direction) : Asset.arrange(arrangeable)).map(&:title) }
        it { should == expected_order }
      end      
    end
    
    it_should_behave_like "arranged assets", :title, nil, ["Cheese of the Damned", "Foo Bar: The Bazzening", "Undercover Foo"]
    it_should_behave_like "arranged assets", :description, nil, ["Foo Bar: The Bazzening", "Cheese of the Damned", "Undercover Foo"]
    it_should_behave_like "arranged assets", :tag, nil, ["Undercover Foo", "Cheese of the Damned", "Foo Bar: The Bazzening"]
    
    it_should_behave_like "arranged assets", :title, :asc, ["Cheese of the Damned", "Foo Bar: The Bazzening", "Undercover Foo"]
    it_should_behave_like "arranged assets", :description, :asc, ["Foo Bar: The Bazzening", "Cheese of the Damned", "Undercover Foo"]
    it_should_behave_like "arranged assets", :tag, :asc, ["Undercover Foo", "Cheese of the Damned", "Foo Bar: The Bazzening"]
    
    it_should_behave_like "arranged assets", :title, :desc, ["Undercover Foo", "Foo Bar: The Bazzening", "Cheese of the Damned"]
    it_should_behave_like "arranged assets", :description, :desc, ["Undercover Foo", "Cheese of the Damned", "Foo Bar: The Bazzening"]
    it_should_behave_like "arranged assets", :tag, :desc, ["Foo Bar: The Bazzening", "Cheese of the Damned", "Undercover Foo"]
  end
end