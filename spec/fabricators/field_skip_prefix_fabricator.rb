Fabricator(:field_skip_prefix) do
  name { Fabricate.sequence(:name) {|i| "test-#{i}"} }
end