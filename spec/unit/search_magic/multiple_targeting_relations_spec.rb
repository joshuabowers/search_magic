require "spec_helper"

describe SearchMagic do
  context "when dealing with a document which has multiple relations targeting the same class" do
    subject { Ticket }
    it { expect { subject.searchables }.should_not raise_error }
    its("searchables.keys") { should include(:assignee_name, :opener_name)}
  end
end