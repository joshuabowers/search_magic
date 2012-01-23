Fabricator(:user) do
  name { Fabricate.sequence(:user_name) {|i| "user-name-#{i}"} }
  watchlists(:count => 5) {|user, watchlist| Fabricate(:watchlist, :user => user)}
end