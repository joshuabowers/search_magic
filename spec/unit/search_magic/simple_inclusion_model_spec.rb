describe SearchMagic do
  context "when included in a model" do
    subject { SimpleInclusionModel }
    it { should respond_to(:search_on, :search_for, :searchables) }
    its("searchables.keys") { should include(:foo, :bar) }
  end
end