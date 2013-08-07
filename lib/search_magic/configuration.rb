module SearchMagic
  {
    :selector_value_separator => ':', 
    :presence_detector => '?', 
    :default_search_mode => :all
  }.each do |key, value|
    config_accessor(key, instance_accessor: false)
    self.send(:"#{key}=", value)
  end
end