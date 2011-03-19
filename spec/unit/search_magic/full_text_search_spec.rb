require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "searchable_fields" do
    context "when called with :serial and :status" do
      it "should create a class attribute called :_searchable_fields and make it a Hash" do
        Part.should respond_to(:_searchable_fields)
        Part._searchable_fields.should be_a(Hash)
      end
      
      it "should create a field called :_searchable_values" do
        Part.fields.keys.should include("_searchable_values")
      end
      
      it "should add :serial and :status to :_searchable_fields" do
        Part._searchable_fields.keys.should include(:serial, :status) 
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