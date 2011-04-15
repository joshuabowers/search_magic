describe SearchMagic do
  context "when included in a model which defines field types" do
    subject { ModelWithFieldTypes.searchables }
    it { subject[:generic_field].type.should == Object }
    it { subject[:generic_field].comparable?.should be_false }
    it { subject[:string_field].type.should == String }
    it { subject[:string_field].comparable?.should be_true }
    it { subject[:float_field].type.should == Float }
    it { subject[:float_field].comparable?.should be_true }
    it { subject[:int_field].type.should == Integer }
    it { subject[:int_field].comparable?.should be_true }
    it { subject[:date_field].type.should == Date }
    it { subject[:date_field].comparable?.should be_true }
    it { subject[:bool_field].type.should == Boolean }
    it { subject[:bool_field].comparable?.should be_false }
    it { subject[:some_value].type.should == Object }
    it { subject[:some_value].comparable?.should be_false }
  end
end