class Abuser
  include Mongoid::Document
  include SearchMagic
  field :name
  has_many :assigned_tickets, class_name: "Ticket", inverse_of: :assignee
  has_many :opened_tickets, class_name: "Ticket", inverse_of: :opener
  
  search_on :name
  search_on :assigned_tickets
  search_on :opened_tickets
end