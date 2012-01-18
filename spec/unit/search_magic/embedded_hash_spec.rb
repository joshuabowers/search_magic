require 'spec_helper'

describe SearchMagic do
  context "when a model includes an embedded hash" do
    subject { Video }
    its("searchables.keys") { should == [:title, :metadata] }
  end
  
  context "a model with an embedded hash" do
    subject { Video.searchables[:metadata] }
    it { should be_hashable }
  end
  
  context "searching for a model with an embedded hash" do
    before(:each) do
      Fabricate(:video, :metadata => {"resolution" => "1080p"})
      Fabricate(:video, :metadata => {"resolution" => "1080i"})
      Fabricate(:video, :metadata => {"resolution" => "720p"})
      Fabricate(:video, :metadata => {"director" => "Alan Smithee"})
    end
    
    shared_examples_for "an embedded hash" do |key, expected_value|
      let(:criteria) { "metadata:#{key}:#{expected_value}" }
      context "the criteria" do
        subject { Video.search_for(criteria) }
        its(:count) { should == 1 }
        it { subject.first.metadata[key] =~ /#{expected_value}/ }
      end
    end
    
    it_should_behave_like "an embedded hash", "resolution", "1080p"
    it_should_behave_like "an embedded hash", "resolution", "1080i"
    it_should_behave_like "an embedded hash", "resolution", "720p"
    it_should_behave_like "an embedded hash", "director", "Smithee"
  end
end