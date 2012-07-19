class SearchableValue
  include Mongoid::Document
  include Mongoid::Timestamps
  field :word, type: String
  field :matching_fields, type: Hash
  embedded_in :searchable, polymorphic: true
end