require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "model includes embedded document fields in :searchable_fields" do
    subject { Person }
    it { subject.searchable_fields.keys.should include(:address) }
    it { subject.searchable_fields.keys.should include(:phones) }
  end
  
  describe "model includes referenced document fields in :searchable_fields" do
    subject { Person }
    it { subject.searchable_fields.keys.should include(:parts) }
  end
  
  context "model embeds one other document" do
    before do
      Person.create(:name => "Joshua", :address => {:street => "123 Example St.", :city => "Nowhereland", :state => "CA", :post_code => 12345})
      Person.create(:name => "Samuel", :address => {:street => "4010 Arbitrary Ave.", :city => "Somewhere", :state => "MO", :post_code => 54321})
    end
    
    describe "model should have embedded document fields in :_searchable_values"
    subject { Person.where(:name => "Joshua").first }
    it { subject.address.should_not be_nil }
    it { subject._searchable_values.should include("address_street:123", "address_street:example", "address_street:st") }
  end
end