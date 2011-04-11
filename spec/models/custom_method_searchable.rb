class CustomMethodSearchable
  include Mongoid::Document
  include Mongoid::Timestamps
  include SearchMagic::FullTextSearch
  
  search_on :random_value
  search_on :date_value
  
  def random_value
    @random_value ||= rand(100)
  end
  
  def date_value
    (created_at || Time.now).to_date + 15
  end
end