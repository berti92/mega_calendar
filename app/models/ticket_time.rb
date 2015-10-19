class TicketTime < ActiveRecord::Base
  unloadable
  belongs_to(:issue)
  attr_accessible :time_begin
  attr_accessible :time_end
  attr_accessible :issue_id
end
