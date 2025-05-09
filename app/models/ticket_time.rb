class TicketTime < ActiveRecord::Base
  belongs_to(:issue)
end
