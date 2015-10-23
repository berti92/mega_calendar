class Holiday < ActiveRecord::Base
  unloadable
  attr_accessible :user_id
  attr_accessible :start
  attr_accessible :end
  belongs_to(:user)
  validates :start, :date => true
  validates :end, :date => true
  validates_presence_of :start, :end
  validate :validate_holiday
  
  def validate_holiday
    if self.start && self.end && (start_changed? || end_changed?) && self.end < self.start
      errors.add :end, :greater_than_start
    end
  end
end
