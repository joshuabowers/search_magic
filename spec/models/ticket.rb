class Ticket
  include Mongoid::Document
  include SearchMagic
  field :issue, type: String
  belongs_to :assignee, class_name: "Abuser", inverse_of: :assigned_tickets
  belongs_to :opener, class_name: "Abuser", inverse_of: :opened_tickets
  
  search_on :assignee
  search_on :opener
end