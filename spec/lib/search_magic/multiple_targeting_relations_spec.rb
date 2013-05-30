require "spec_helper"

describe SearchMagic do
  context "when dealing with a document which has multiple relations targeting the same class" do
    subject { Ticket }
    its("searchables.keys") { should include(:assignee_name, :opener_name)}
  end
end