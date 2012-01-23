describe SearchMagic::FullTextSearch do
  context "when searching for \"title:'foo bar'\"" do
    subject { Asset.search_for("title:'foo bar'") }
    its("selector.keys") { should include(:searchable_values) }
    it { subject.selector[:searchable_values]["$all"].should include(/^title:.*foo/i, /^title:.*bar/i)}
  end
  
  context "when searching for 'title:\"foo bar\"'" do
    subject { Asset.search_for('title:"foo bar"') }
    its("selector.keys") { should include(:searchable_values) }
    it { subject.selector[:searchable_values]["$all"].should include(/^title:.*foo/i, /^title:.*bar/i)}
  end
  
  context "when searching for 'title:foo title:bar'" do
    subject { Asset.search_for('title:foo title:bar') }
    its("selector.keys") { should include(:searchable_values) }
    it { subject.selector[:searchable_values]["$all"].should include(/^title:.*foo/i, /^title:.*bar/i)}
  end
end