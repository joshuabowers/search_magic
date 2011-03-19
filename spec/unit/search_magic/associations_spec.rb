require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "model includes embedded document fields in :searchable_fields" do
    subject { Person }
    it { subject.searchable_fields.keys.should include(:address) }
    it { subject.searchable_fields.keys.should include(:phones) }
    it { should respond_to(:searchables)}
    its(:searchables) { should include(:address_street, :address_city, :address_state, :address_post_code, :mobile_numbers)}
  end
  
  describe "model includes referenced document fields in :searchable_fields" do
    subject { Person }
    it { subject.searchable_fields.keys.should include(:parts) }
    its(:searchables) { should include(:part_serials) }
  end
  
  context "model embeds one other document" do
    before do
      Person.create(:name => "Joshua", :address => {:street => "123 Example St.", :city => "Nowhereland", :state => "CA", :post_code => 12345})
      Person.create(:name => "Samuel", :address => {:street => "4010 Arbitrary Ave.", :city => "Somewhere", :state => "MO", :post_code => 54321})
    end
    
    describe "model should have embedded document fields in :_searchable_values" do
      subject { Person.where(:name => "Joshua").first }
      it { subject.address.should_not be_nil }
      it { subject._searchable_values.should include("address_street:123", "address_street:example", "address_street:st") }
    end
    
    context "when searching for 'address_city:nowhereland'" do
      subject { Person.search("address_city:nowhereland") }
      its("selector.keys") { should include(:_searchable_values) }
      its(:count) { should == 1 }
      its("first.name") { should == "Joshua" }
    end
    
    context "when searching for 'arbitrary address_post_code:54321'" do
      subject { Person.search("arbitrary address_post_code:54321") }
      its(:count) { should == 1 }
      its("first.name") { should == "Samuel" }
    end
  end
  
  context "model relates to many other documents" do
  end
  
  context "model relates to many other documents through another document" do
    
  end
end