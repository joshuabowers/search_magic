class AbsolutelyNotSearchable
  include Mongoid::Document
  field :foo, :type => String
  referenced_in :is_searchable
end