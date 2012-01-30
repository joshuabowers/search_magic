class Ticket
  include Mongoid::Document
  include SearchMagic
  field :issue, type: String
  referenced_in :assignee, class_name: "Abuser", inverse_of: :assigned_tickets
  referenced_in :opener, class_name: "Abuser", inverse_of: :opened_tickets
  
  search_on :assignee
  search_on :opener
end