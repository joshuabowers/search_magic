describe SearchMagic do
  it { should respond_to(:config) }
  
  context "with no configuration for :selector_value_separator" do
    before(:each) { SearchMagic.config.selector_value_separator = nil }
    after(:each) { SearchMagic.config.selector_value_separator = nil }
  end
  
  context "with a configuration for :selector_value_separator of ':'" do
    before(:each) { SearchMagic.config.selector_value_separator = ':' }
    after(:each) { SearchMagic.config.selector_value_separator = nil }
  end
  
  context "with a configuration for :selector_value_separator of '/'" do
    before(:each) { SearchMagic.config.selector_value_separator = '/' }
    after(:each) { SearchMagic.config.selector_value_separator = nil }
  end
end