require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "included" do
    subject { NoSearchFields }
    
    it "should add a class method called :searchable_field" do
      should respond_to(:searchable_field)
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
  end
  
  describe "searchable_field" do
    context "when called with :serial and :status" do
      it "should add :serial and :status to :searchable_fields" do
        Part.searchable_fields.keys.should include(:serial, :status) 
      end
      
      it "should not have :category in :searchable_fields" do
        Part.searchable_fields.keys.should_not include(:category)
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
end