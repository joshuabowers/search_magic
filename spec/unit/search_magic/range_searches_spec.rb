require 'spec_helper'

describe SearchMagic do
  context "when searching a model" do
    before(:each) do
      Fabricate(:game, :high_score => 250, :price => 19.95, :released_on => 2.weeks.ago)
      Fabricate(:game, :high_score => 500, :price => 49.95, :released_on => 6.weeks.ago)
      Fabricate(:game, :high_score => 750, :price => 59.95, :released_on => 4.months.ago)
      Fabricate(:game, :high_score => 1000, :price => 79.95, :released_on => 8.months.ago)
      Fabricate(:game, :high_score => 1250, :price => 99.95, :released_on => 4.years.ago)
      Fabricate(:game, :high_score => 1500, :price => 149.95, :released_on => 15.years.ago)
    end
    
    shared_examples_for "a simple range search" do |field, selector, value, expected_count|
      context "the criteria" do
        subject { Game.search_for("#{field}:#{selector}:#{value}") }
        its(:count) { should == expected_count }
      end
      context "the instances" do
        Game.search_for("#{field}:#{selector}:#{value}").each do |game|
          context game do
            case selector
            when :below, :before
              its(field) { should be < value }
            when :above, :after
              its(field) { should be > value }
            end
          end
        end
      end
    end
    
    context "with a :below selector" do
      it_should_behave_like "a simple range search", :high_score, :below, 1000, 3
    end
    
    context "with a :before selector" do
      pending
    end
    
    context "with an :above selector" do
      pending
    end
    
    context "with an :after selector" do
      pending
    end
  end
end