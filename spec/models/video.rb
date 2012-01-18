class Video
  include Mongoid::Document
  include SearchMagic
  field :title, :type => String
  field :metadata, :type => Hash, :default => {}
  search_on :title
  search_on :metadata, :as => :metadata
end