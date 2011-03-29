describe SearchMagic::FullTextSearch do
  context "when included in a document without searchables" do
    subject { NoSearchables }
    it { should respond_to(:inverse_searchables) }
    its(:inverse_searchables) { should be_a(Array)}
    its(:inverse_searchables) { should be_blank }
  end
  
  context "when included in a document which is not searched on from another document" do
    subject { Person }
    it { should respond_to(:inverse_searchables) }
    its(:inverse_searchables) { should be_a(Array)}
    its(:inverse_searchables) { should be_blank }
  end
  
  context "when included in a document with embedded searchables" do
    subject { Address }
    it { should respond_to(:inverse_searchables) }
    its(:inverse_searchables) { should be_a(Array) }
    its(:inverse_searchables) { should_not be_blank }
    its(:inverse_searchables) { should include(:person) }
  end
  
  context "when included in a document with referenced searchables" do
    subject { PartNumber }
    it { should respond_to(:inverse_searchables) }
    its(:inverse_searchables) { should be_a(Array) }
    its(:inverse_searchables) { should_not be_blank }
    its(:inverse_searchables) { should include(:parts) }
    its(:inverse_searchables) { should_not include(:part_categories) }
  end
  
  context "when included in a document which is searched on by another document, but which does not search on another" do
    subject { PartCategory }
    its(:inverse_searchables) { should include(:part_numbers) }
  end
  
  context "when an embedded model is updated" do
    before(:each) do
      Person.create(:name => "Joshua", :address => {:street => "123 Example St.", :city => "Nowhereland", :state => "CA", :post_code => 12345}, :phones => [{:country_code => 1, :number => "555-1234"}, {:country_code => 2, :number => "333-7890"}])
    end
    
    describe "the top-level document should have its :searchable_values and :arrangeable_values updated" do
      subject { Person.first }
      before(:each) { subject.address.update_attributes!(:city => "Nowhereville") && subject.reload }
      its(:searchable_values) { should include("address_city:nowhereville") }
      its(:searchable_values) { should_not include("address_city:nowhereland") }
      its(:arrangeable_values) { should include("address_city" => "Nowhereville") }
      its(:arrangeable_values) { should_not include("address_city" => "Nowhereland") }
    end
  end
  
  context "when a referenced model is updated the current model's :searchable_values should change" do
    before(:each) do
      PartCategory.create(:name => "Table").tap do |category|
        category.part_numbers.create(:value => "T11001").tap do |number|
          number.parts.create(:status => "available", :serial => "T0411001")
        end
      end
    end
    
    describe "when a model is updated" do
      subject { PartNumber.first }
      before(:each) { subject.part_category.update_attributes!(:name => "Desk" ) && subject.reload }
      its(:searchable_values) { should include("category_name:desk") }
      its(:searchable_values) { should_not include("category_name:table") }
      its(:arrangeable_values) { should include("category_name" => "Desk") }
      its(:arrangeable_values) { should_not include("category_name" => "Table") }
    end
    
    describe "when a deeply nested model is updated" do
      subject { Part.first }
      before(:each) { subject.part_number.part_category.update_attributes!(:name => "Desk" ) && subject.reload }
      its(:searchable_values) { should include("category_name:desk") }
      its(:searchable_values) { should_not include("category_name:table") }
      its(:arrangeable_values) { should include("category_name" => "Desk") }
      its(:arrangeable_values) { should_not include("category_name" => "Table") }
    end
  end
end