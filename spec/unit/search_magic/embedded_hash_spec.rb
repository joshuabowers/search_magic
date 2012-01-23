require 'spec_helper'

describe SearchMagic do
  context "when a model includes an embedded hash" do
    subject { Video }
    its("searchables.keys") { should == [:title, :extra] }
    its(:searchable_names) { should == "title|extra:[^:\\s]+"}
  end
  
  context "a model with an embedded hash" do
    subject { Video.searchables[:extra] }
    it { should be_hashable }
  end
  
  context "searching for a model with an embedded hash" do
    before(:each) do
      Fabricate(:video, :extra => {"resolution" => "1080p"})
      Fabricate(:video, :extra => {"resolution" => "1080i"})
      Fabricate(:video, :extra => {"resolution" => "720p"})
      Fabricate(:video, :extra => {"director" => "Alan Smithee"})
    end
    
    shared_examples_for "an embedded hash" do |key, expected_value|
      context "the criteria" do
        subject { Video.search_for("extra:#{key}:#{expected_value}") }
        its(:selector) { should == {:searchable_values => {"$all" => expected_value.gsub(/^'([^']+)'$/, '\1').split.map {|word| /^extra:#{key}:.*#{word}/i }}}}
        its(:count) { should == 1 }
      end
      context "the instance" do
        Video.search_for("extra:#{key}:#{expected_value}").each do |video|
          context video do
            its(:metadata) { should_not be_blank }
            it { video.metadata[key].should =~ /#{expected_value}/i }
          end
        end
      end
    end
    
    it_should_behave_like "an embedded hash", "resolution", "1080p"
    it_should_behave_like "an embedded hash", "resolution", "1080i"
    it_should_behave_like "an embedded hash", "resolution", "720p"
    it_should_behave_like "an embedded hash", "director", "smithee"
    it_should_behave_like "an embedded hash", "director", "alan"
    it_should_behave_like "an embedded hash", "director", "'alan smithee'"
  end
end