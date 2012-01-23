Fabricator(:watchlist) do
  description { Fabricate.sequence(:watchlist_description) {|i| "watchlist-#{i}"} }
end