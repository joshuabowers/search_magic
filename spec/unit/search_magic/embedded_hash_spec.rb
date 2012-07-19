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
    
    shared_examples_for "an embedded hash" do |key, expected_value, expected_count|
      if expected_value.present?
        context "the criteria \"extra:#{key}:#{expected_value}\"" do
          subject { Video.search_for("extra:#{key}:#{expected_value}") }
          its(:selector) { should == {"searchable_values" => {"$all" => expected_value.gsub(/^'([^']+)'$/, '\1').split.map {|word| /^extra:#{key}:.*#{word}/i }}}}
          its(:count) { should == 1 }
        end
        context "the instance" do
          Video.search_for("extra:#{key}:#{expected_value}").each do |video|
            context video do
              its(:extra) { should_not be_blank }
              it { video.extra[key].should =~ /#{expected_value}/i }
            end
          end
        end
      end
      context "the criteria \"extra:#{key}?\"" do
        subject { Video.search_for("extra:#{key}?") }
        its(:selector) { should == {"searchable_values" => {"$all" => [/^extra:#{key}:[^:\s]+/i]} }}
        its(:count) { should == expected_count }
      end
    end
    
    it_should_behave_like "an embedded hash", "resolution", "1080p", 3
    it_should_behave_like "an embedded hash", "resolution", "1080i", 3
    it_should_behave_like "an embedded hash", "resolution", "720p", 3
    it_should_behave_like "an embedded hash", "director", "smithee", 1
    it_should_behave_like "an embedded hash", "director", "alan", 1
    it_should_behave_like "an embedded hash", "director", "'alan smithee'", 1
    it_should_behave_like "an embedded hash", "widget", nil, 0
    
    context "an instance's values_matching" do
      subject { Video.search_for("extra:resolution?").first.values_matching("extra:resolution?") }
      it { should include("extra:resolution:1080p") }
    end
  end
end