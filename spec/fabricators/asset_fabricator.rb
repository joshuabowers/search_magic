Fabricator(:asset) do
  title { Fabricate.sequence(:title) { |i| "asset-title-#{i}" } }
  description "Generic description."
  tags { %w{foo b.a.r b-az q:ux z!png p'zow}.sample(rand(6)) }
  uuid { "ae9d14ee-be93-11df-9fec-78ca39fffe11" }
end