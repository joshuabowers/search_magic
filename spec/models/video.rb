class Video
  include Mongoid::Document
  include SearchMagic
  field :title, :type => String
  field :extra, :type => Hash, :default => {}
  search_on :title
  search_on :extra
end