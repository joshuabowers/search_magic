class AbsolutelyNotSearchable
  include Mongoid::Document
  field :foo, :type => String
  belongs_to :is_searchable
end