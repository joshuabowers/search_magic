require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "searchable_fields" do
    context "when called with :serial and :status" do
      it "should create a field called :_searchable_values" do
        Part.fields.keys.should include("_searchable_values")
      end
    end
  end
end