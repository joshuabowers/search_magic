describe SearchMagic do
  it { should respond_to(:config) }

  shared_examples_for "selector_value_separator" do |separator|
    context "with a configuration for :selector_value_separator of '#{separator}'" do
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