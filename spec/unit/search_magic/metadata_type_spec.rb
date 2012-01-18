describe SearchMagic do
  shared_examples_for "metadata" do |field, type, comparable, search_regex_fragment|
    subject { ModelWithFieldTypes.searchables[field] }
    its(:type) { should == type }
    its(:comparable?) { should == comparable }
    its(:search_regex_fragment) { should == search_regex_fragment }
  end
  
  context "when included in a model which defines field types" do
    it_behaves_like "metadata", :generic_field, Mongoid::Fields::Serializable::Object, false, "generic_field"
    it_behaves_like "metadata", :string_field, String, true, "string_field"
    it_behaves_like "metadata", :float_field, Float, true, "float_field"
    it_behaves_like "metadata", :int_field, Integer, true, "int_field"
    it_behaves_like "metadata", :date_field, Date, true, "date_field"
    it_behaves_like "metadata", :bool_field, Boolean, false, "bool_field"
    it_behaves_like "metadata", :some_value, Object, false, "some_value"
    it_behaves_like "metadata", :hash_field, Hash, false, "hash_field:[^:\\s]+"
  end
end