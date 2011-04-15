Fabricator(:developer) do
  name { Fabricate.sequence(:developer_name) { |i| "developer-#{i}" } }
  opened_on { Time.at(rand * Time.now.to_f) }
end