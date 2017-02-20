class UserFilter < ActiveRecord::Base
  unloadable
  belongs_to(:user)
  attr_accessible :user_id
  attr_accessible :filter_name
  attr_accessible :filter_code
end
