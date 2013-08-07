Fabricator(:user) do
  name { Fabricate.sequence(:user_name) {|i| "user-name-#{i}"} }
  watchlists(count: 5)# {|attrs, watchlist| Fabricate(:watchlist, user: self)}
end