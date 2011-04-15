require 'spec_helper'

describe SearchMagic do
  context "when searching for natural language dates and times" do
    subject { Developer.search_for("opened_on:yesterday") }
    its(:selector) { should_not include(:searchable_values => {"$all" => [/opened_on:.*yesterday/i]}) }
    it { subject.selector[:searchable_values]["$all"].first.to_s.should match(/opened_on:#{1.day.ago.to_date}/)}
  end
  
  context "when searching for a complex natural language date or time" do
    subject { Developer.search_for("opened_on:'1 year ago'") }
    its(:selector) { should_not include(:searchable_values => {"$all" => [/opened_on:.*1/i, /opened_on:.*year/i, /opened_on:.*ago/i]}) }
    it { subject.selector[:searchable_values]["$all"].first.to_s.should match(/opened_on:#{1.year.ago.to_date}/)}
  end
end