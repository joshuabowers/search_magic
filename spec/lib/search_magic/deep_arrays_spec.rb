require 'spec_helper'

describe "A model with a searchable array" do
  subject { Location }
  it { should respond_to("searchables")}
  its('searchables.keys') { should == [:keyword] }
end

describe "A model which nests and searches on a model with a searchable array" do
  subject { Program }
  its('searchables.keys') { should == [:location_keyword] }
end

describe "A model which deeply embeds and searches another model with arrays" do
  subject { Organization }
  its('searchables.keys') { should == [:program_location_keyword] }
end

describe "Search a deeply embedded array" do
  before { Fabricate(:organization) }
  it { expect { Organization.search_for("program_location_keyword:lorem") }.to_not raise_error }
end