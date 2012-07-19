require "spec_helper"

describe SearchMagic do
  context "when included in a mongoid document, instances" do
    subject { Fabricate(:game, title: "Donkey Kong") }
    it { should respond_to(:svalues) }
  end
  
  context "a searchable_value" do
    subject { Fabricate(:game).svalues.first }
    it { should be_a(SearchableValue) }
  end
end