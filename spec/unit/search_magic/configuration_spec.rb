describe SearchMagic do
  it { should respond_to(:config) }

  context "global option: selector_value_separator" do
    shared_examples_for "selector_value_separator" do |separator|
      context "with a configuration for :selector_value_separator of #{separator.inspect}" do
        let(:tags) { %w{foo b.a.r b-az q:ux z!png p'zow} }
        before(:each) { SearchMagic.config.selector_value_separator = separator }
        before(:each) { Fabricate(:asset, :tags => tags) }
        after(:each) { SearchMagic.config.selector_value_separator = nil }
        let(:asset) { Asset.first }
        describe do
          subject { asset }
          its(:searchable_values) { should include( *tags.map {|tag| "tag#{separator || ':'}#{tag}"} ) }
        end
        describe "searching for models should use '#{separator || ':'}'" do
          subject { Asset.search_for("tag#{separator || ':'}foo") }
          its(:count) { should == 1 }
          its(:first) { should == asset }
        end
      end
    end
  
    it_should_behave_like "selector_value_separator", nil
    it_should_behave_like "selector_value_separator", ':'
    it_should_behave_like "selector_value_separator", '/'
    it_should_behave_like "selector_value_separator", '-'
    it_should_behave_like "selector_value_separator", '!'
  end
  
  context "global option: default_search_mode" do
    before(:each) do
      Fabricate(:asset, :tags => %w[b.a.r p'zow z!png dirigible])
      Fabricate(:asset, :tags => %w[foo b-az q:ux dirigible])
    end
    
    shared_examples_for "default_search_mode" do |default_search_mode, expected_count, should_fail|
      context "with a configuration for :default_search_mode of #{default_search_mode.inspect}" do
        let(:pattern) { "dirigible z!png" }
        before(:each) { SearchMagic.config.default_search_mode = default_search_mode }
        after(:each) { SearchMagic.config.default_search_mode = nil }
        describe "searching without an explicit mode" do
          subject { Asset.search_for(pattern) }
          its(:count) { should == expected_count }
        end
      end
    end
    
    it_should_behave_like "default_search_mode", nil, 1
    it_should_behave_like "default_search_mode", "all", 1
    it_should_behave_like "default_search_mode", "any", 2
    it_should_behave_like "default_search_mode", :all, 1
    it_should_behave_like "default_search_mode", :any, 2
    it_should_behave_like "default_search_mode", "unsupported", 1
  end
end