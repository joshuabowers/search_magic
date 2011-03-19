require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "included" do
    subject { NoSearchFields }
    
    it "should add a class method called :search_on" do
      should respond_to(:search_on).with(2).arguments
    end
    
    it "should create a class attribute called :searchable_fields and make it a Hash" do
      should respond_to(:searchable_fields)
      subject.searchable_fields.should be_a(Hash)
    end
    
    it "should have no :searchable_fields" do
      subject.searchable_fields.should be_empty
    end
    
    it "should create a field called :_searchable_values and make it an empty Array" do
      subject.fields.keys.should include("_searchable_values")
      subject.fields["_searchable_values"].type.should == Array
      subject.fields["_searchable_values"].default.should == []
    end
    
    it { should respond_to(:search).with(1).argument }
  end
  
  describe "searchable_field" do
    context "when called with :serial and :status" do
      describe "searchable_fields should have" do
        subject { Part }
        
        its("searchable_fields.keys") { should include(:serial, :status) }
        its("searchable_fields.keys") { should_not include(:category) }
      
        its(:searchables) { should include(:serial, :status) }
        its(:searchables) { should_not include(:category) }
      end
      
      describe "update searchable values" do
        subject { Part.new(:status => "available", :serial => "1234abcd", :category => "widget") }
        
        it "should run the update_searchable_values callback" do
          subject.should_receive(:update_searchable_values)
          subject.run_callbacks(:save)
        end
        
        it "should have values in :_searchable_values" do
          subject.run_callbacks(:save)
          subject._searchable_values.should_not be_empty
        end
        
        it "should have entries for each field in :searchable_fields" do
          subject.run_callbacks(:save)
          Part.searchable_fields.keys.each do |field_name|
            subject._searchable_values.should include("#{field_name}:#{subject.send(field_name)}")
          end
        end
        
        it "should not have entries in :_searchable_values for fields not included in :searchable_fields" do
          subject.run_callbacks(:save)
          (Part.fields.keys - Part.searchable_fields.keys.map(&:to_s)).each do |field_name|
            subject._searchable_values.should_not include("#{field_name}:#{subject.send(field_name)}")
          end
        end
      end
    end
  end
  
  describe :search do
    context "any model" do
      it { NoSearchFields.search("foo bar").should be_a(Mongoid::Criteria) }
    end
    
    context "no search fields" do
      it { NoSearchFields.search("foo").count.should == 0 }
    end
    
    context "defined search fields :status and :serial" do
      before do 
        Part.create(:status => "available", :serial => "1234abcd", :category => "widget")
        Part.create(:status => "available", :serial => "4321dcba", :category => "object")
        Part.create(:status => "defective", :serial => "7890qwer", :category => "widget")
      end
      
      context "when searching for anything" do
        subject { Part.search("foo") }
        it { subject.selector.keys.should include(:_searchable_values) }
      end
      
      context "when searching for nothing" do
        it { Part.search(nil).selector.keys.should_not include(:_searchable_values) }
        it { Part.search("").selector.keys.should_not include(:_searchable_values) }
      end
      
      context "when searching for 'available'" do
        subject { Part.search("available") }
        its(:count) { should == 2 }
        it { subject.each {|item| item.status.should == "available"} }
      end
      
      context "when searching for 'status:available'" do
        subject { Part.search("status:available") }
        its(:count) { should == 2 }
        it { subject.each {|item| item.status.should == "available"} }
      end
      
      context "when searching for 'serial:available'" do
        subject { Part.search("serial:available") }
        its(:count) { should == 0 }
      end
      
      context "when searching for 'status:avail serial:1234'" do
        subject { Part.search("status:avail serial:1234") }
        its(:count) { should == 1 }
        its("first.status") { should == "available" }
        its("first.serial") { should == "1234abcd" }
      end
    end
  end
end