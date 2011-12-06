Fabricator(:game) do
  title { Fabricate.sequence(:game) {|i| "Game Title #{i}"} }
  price { [19.95, 45.50, 59.99, 79.99, 99.99].sample }
  high_score { 500 + rand(1000) }
  released_on { [1.month.ago, 6.months.ago, 1.year.ago, 10.years.ago].sample.to_date }
end