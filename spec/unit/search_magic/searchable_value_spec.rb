require "spec_helper"

describe SearchMagic do
  context "contains searchable values" do
    it { should.respond_to(:searchable_values) }
  end
end