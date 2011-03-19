require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "included" do
    before do
      @class = NoSearchFields
    end
    
    it "should add a class method called :searchable_field" do
      @class.should respond_to(:searchable_field)
    end
    
    it "should create a class attribute called :searchable_fields and make it a Hash" do
      @class.should respond_to(:searchable_fields)
      @class.searchable_fields.should be_a(Hash)
    end
    
    it "should have no :searchable_fields" do
      @class.searchable_fields.should be_empty
    end
    
    it "should create a field called :_searchable_values" do
      @class.fields.keys.should include("_searchable_values")
    end
  end
  
  describe "searchable_field" do
    context "when called with :serial and :status" do
      it "should add :serial and :status to :searchable_fields" do
        Part.searchable_fields.keys.should include(:serial, :status) 
      end
      
      describe "before_save" do
        before do
          @part = Part.new(:status => "available", :serial => "1234abcd")
        end
        
        it "should run the update_searchable_values callback" do
          @part.should_receive(:update_searchable_values)
          @part.save
        end
      end
    end
  end
end