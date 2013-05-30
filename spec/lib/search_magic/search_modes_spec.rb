require 'spec_helper'

describe SearchMagic do
  context "the model class" do
    subject { Asset }
    it { should respond_to(:strip_option_terms_from).with(1).argument }
    it { subject.strip_option_terms_from(nil).should == [{}, nil] }
    it { subject.strip_option_terms_from("tag:foo").should == [{}, "tag:foo"] }
    it { subject.strip_option_terms_from("mode:any tag:foo").should == [{:mode => "any"}, "tag:foo"] }
    it { subject.strip_option_terms_from("mode:all tag:foo").should == [{:mode => "all"}, "tag:foo"] }
    it { subject.strip_option_terms_from("mode:all mode:any").should == [{:mode => "any"}, ""] }
    it { subject.strip_option_terms_from("mode:any mode:all").should == [{:mode => "all"}, ""] }
    it { subject.strip_option_terms_from("mode:all mode:any mode:all").should == [{:mode => "all"}, ""] }
  end
  context "when searching" do
    before(:each) do
      5.times { Fabricate(:asset, :tags => %w[b.a.r p'zow z!png dirigible]) }
      5.times { Fabricate(:asset, :tags => %w[foo b-az q:ux dirigible]) }
    end
  
    shared_examples_for "search" do |pattern, expected_count|
      subject { Asset.search_for(pattern) }
      its(:count) { should == expected_count }
    end
  
    context "without a search mode" do
      it_should_behave_like "search", "tag:foo tag:b.a.r", 0
      it_should_behave_like "search", "tag:foo tag:b-az", 5
      it_should_behave_like "search", "tag:dirigible", 10
      it_should_behave_like "search", "tag:foo tag:dirigible", 5
    end
  
    context "with a search mode" do
      context "of all" do
        it_should_behave_like "search", "mode:all tag:foo tag:b.a.r", 0
        it_should_behave_like "search", "mode:all tag:foo tag:b-az", 5
        it_should_behave_like "search", "mode:all tag:dirigible", 10
        it_should_behave_like "search", "mode:all tag:foo tag:dirigible", 5
      end
    
      context "of any" do
        it_should_behave_like "search", "mode:any tag:foo tag:b.a.r", 10
        it_should_behave_like "search", "mode:any tag:foo tag:b-az", 5
        it_should_behave_like "search", "mode:any tag:dirigible", 10
        it_should_behave_like "search", "mode:any tag:foo tag:dirigible", 10
      end
    end
  end
end