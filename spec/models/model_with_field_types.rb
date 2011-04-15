class ModelWithFieldTypes
  include Mongoid::Document
  include SearchMagic
  field :generic_field
  field :string_field, :type => String
  field :int_field, :type => Integer
  field :date_field, :type => Date
  field :float_field, :type => Float
  field :bool_field, :type => Boolean
  
  def some_value
    true
  end
  
  search_on :generic_field
  search_on :string_field
  search_on :int_field
  search_on :date_field
  search_on :float_field
  search_on :bool_field
  search_on :some_value
end