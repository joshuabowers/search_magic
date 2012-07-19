require "spec_helper"

describe SearchMagic do
  context "when included in a mongoid document, instances" do
    subject { Fabricate(:game, title: "Donkey Kong") }
    it { should respond_to(:searchable_values) }
  end
  
  context "a searchable_value" do
    subject { Fabricate(:game).searchable_values.first }
    its(:class) { should be == "SearchableValue" }
  end
end