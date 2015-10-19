class Holiday < ActiveRecord::Base
  unloadable
  attr_accessible :user_id
  attr_accessible :start
  attr_accessible :end
  belongs_to(:user)
end
