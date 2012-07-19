describe SearchMagic do
  context "when searching for documents through an attribute of a non-searchable class" do
    before(:each) do
      Fabricate(:user)
    end
    
    context "an embedded documents searchable_values should not be empty" do
      subject { User.first.watchlists.first }
      its(:searchable_values) { should == %w[description:watchlist description:0] }
    end
    
    context "directly searching an embedded document" do
      subject { User.first.watchlists.where(:description => /^([^:]+:)?.*watchlist/i) }
      its(:count) { should == 5 }
    end
    
    context "the terms for a given watchlist" do
      subject { User.first.watchlists.first }
      it { subject.values_matching("watchlist").should == ["description:watchlist"] }
    end
    
    context "directly searching the searchable_values of an embedded document" do
      subject { User.first.watchlists.all_in(:searchable_values => [/^([^:]+:)?.*watchlist/i]) }
      its(:selector) { should == {"searchable_values" => {"$all" => [/^([^:]+:)?.*watchlist/i]}} }
      its(:count) { should == 5 }
    end
    
    context "the search query should be" do
      subject { User.first.watchlists.search_for("watchlist") }
      its(:selector) { should == {"searchable_values" => {"$all" => [/^([^:]+:)?.*watchlist/i]}} }
      it { expect { subject.count }.to_not raise_error }
      its(:count) { should == 5 }
    end
  end
end