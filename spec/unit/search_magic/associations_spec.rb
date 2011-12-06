require 'spec_helper'

describe SearchMagic::FullTextSearch do
  describe "model includes embedded document fields in :searchable_fields" do
    subject { Person }
    it { subject.searchable_fields.keys.should include(:address) }
    it { subject.searchable_fields.keys.should include(:phones) }
    it { should respond_to(:searchables)}
    its("searchables.keys") { should include(:address_street, :address_city, :address_state, :address_post_code, :mobile_number)}
    its("searchables.keys") { should_not include(:mobile_country_code)}
  end
  
  describe "model includes referenced document fields in :searchable_fields" do
    subject { Part }
    it { subject.searchable_fields.keys.should include(:part_number) }
    its("searchables.keys") { should include(:part_number, :category_name) }
  end
  
  context "when a model excludes an associated documents fields" do
    subject { Game }
    its("searchables.keys") { should include(:title, :price, :high_score, :released_on, :developer_name) }
    its("searchables.keys") { should_not include(:developer_opened_on) }
  end
  
  context "when a model only includes certain fields from an associated document" do
    subject { Player }
    its("searchables.keys") { should include(:name, :game_title, :game_developer_name) }
    its("searchables.keys") { should_not include(:game_price, :game_high_score, :game_released_on, :game_developer_opened_on)}
  end
  
  context "when a model embeds one other document" do
    before(:each) do
      Person.create(:name => "Joshua", :address => {:street => "123 Example St.", :city => "Nowhereland", :state => "CA", :post_code => 12345}, :phones => [{:country_code => 1, :number => "555-1234"}, {:country_code => 2, :number => "333-7890"}])
      Person.create(:name => "Samuel", :address => {:street => "4010 Arbitrary Ave.", :city => "New Somewhere", :state => "MO", :post_code => 54321}, :phones => [{:country_code => 5, :number => "444-4321"}, {:country_code => 1, :number => "555-0987"}])
    end
    
    describe "model should have embedded document fields in :searchable_values" do
      subject { Person.where(:name => "Joshua").first }
      its(:address) { should_not be_nil }
      its(:phones) { should_not be_empty }
      its(:searchable_values) { should include("address_street:123", "address_street:example", "address_street:st") }
    end
    
    context "when searching for 'address_city:nowhereland'" do
      subject { Person.search_for("address_city:nowhereland") }
      its("selector.keys") { should include(:searchable_values) }
      its(:count) { should == 1 }
      its("first.name") { should == "Joshua" }
    end
    
    context "when searching for 'arbitrary address_post_code:54321'" do
      subject { Person.search_for("arbitrary address_post_code:54321") }
      its(:count) { should == 1 }
      its("first.name") { should == "Samuel" }
    end
    
    context "when searching for 'mobile_number:555-'" do
      subject { Person.search_for("mobile_number:555-") }
      its(:count) { should == 2 }
    end
    
    context "when searching for 'mobile_number:333-'" do
      subject { Person.search_for("mobile_number:333-") }
      its(:count) { should == 1 }
      its("first.name") { should == "Joshua" }
    end
    
    context "when searching for 'mobile_number:-0987'" do
      subject { Person.search_for("mobile_number:-0987") }
      its(:count) { should == 1 }
      its("first.name") { should == "Samuel" }
    end
  end
  
  context "when a model references other documents" do
    before(:each) do
      PartCategory.create(:name => "Table").tap do |category|
        category.part_numbers.create(:value => "T11001").tap do |number|
          number.parts.create(:status => "available", :serial => "T0411001")
          number.parts.create(:status => "broken", :serial => "T0511010")
        end
        category.part_numbers.create(:value => "T11002").tap do |number|
          number.parts.create(:status => "available", :serial => "T0411037")
          number.parts.create(:status => "broken", :serial => "T0511178")
        end
      end
      PartCategory.create(:name => "Chair").tap do |category|
        category.part_numbers.create(:value => "C11001").tap do |number|
          number.parts.create(:status => "available", :serial => "C0411001")
          number.parts.create(:status => "broken", :serial => "C0511010")
        end
        category.part_numbers.create(:value => "C11002").tap do |number|
          number.parts.create(:status => "available", :serial => "C0411001")
          number.parts.create(:status => "broken", :serial => "C0511010")
        end
      end
    end
    
    context "when a model directly references another document" do
      describe "model should have referenced document fields in :searchable_values" do
        subject { PartNumber.where(:value => "T11001").first }
        it { should be }
        its(:part_category) { should_not be_nil }
        its(:searchable_values) { should include("part_number:t11001", "category_name:table") }
      end
    
      context "when searching for 'category_name:table'" do
        subject { PartNumber.search_for("category_name:table").map(&:value) }
        its(:count) { should == 2 }
        it { should include("T11001", "T11002") }
      end
    
      context "when searching for '11001'" do
        subject { PartNumber.search_for("11001").map(&:value) }
        its(:count) { should == 2 }
        it { should include("T11001", "C11001") }
      end
    end
    
    context "when a model references a document which references another document" do
      describe "model should have :searchables from the indirect reference" do
        subject { Part.where(:serial => "T0411001").first }
        it { Part.count.should == 8 }
        it { should be }
        its(:part_number) { should_not be_nil }
        its(:searchable_values) { should include("part_number:t11001", "category_name:table", "status:available", "serial:t0411001") }
      end
      
      context "when searching for 'category_name:table'" do
        subject { Part.search_for("category_name:table").map(&:serial) }
        its(:count) { should == 4 }
        it { should include("T0411001", "T0511010", "T0411037", "T0511178") }
      end
      
      context "when searching for 'broken chair'" do
        subject { Part.search_for("broken chair").map(&:serial) }
        its(:count) { should == 2 }
        it { should include("C0511010", "C0511010") }
      end
      
      context "when searching for 'part_number:T11001'" do
        subject { Part.search_for("part_number:T11001").map(&:serial) }
        its(:count) { should == 2 }
        it { should include("T0411001", "T0511010") }
      end
    end
  end
end