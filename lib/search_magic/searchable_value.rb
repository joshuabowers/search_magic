require 'mongoid'

class SearchableValue
  include Mongoid::Document
  include Mongoid::Timestamps
  field :word, type: String
  field :matching_fields, type: Hash, default: {}
  field :occurrances, type: Integer, default: 0
  embedded_in :searchable, polymorphic: true
  
  before_save :update_occurrances
  
  def update_occurrances
    self.occurrances = matching_fields.values.sum
  end
end