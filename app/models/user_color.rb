class UserColor < ActiveRecord::Base
  unloadable
  belongs_to(:user)
  attr_accessible :user_id
  attr_accessible :color_code
end
