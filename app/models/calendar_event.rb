class CalendarEvent < ActiveRecord::Base
  unloadable
  attr_accessible :user_id
  attr_accessible :start
  attr_accessible :end
  attr_accessible :title
  belongs_to :user, :class_name => 'Principal'
  #validates :start, :date => true
  #validates :end, :date => true
  validates_presence_of :start, :end, :title
  validate :validate_calendar_event
  
  def validate_calendar_event
    if self.start && self.end && (start_changed? || end_changed?) && self.end < self.start
      errors.add :end, :greater_than_start
    end
  end

  def assignable_users
    types = ['User']
    types << 'Group' if Setting.issue_group_assignment?

    @assignable_users ||= Principal.
      active.
      joins(:members => :roles).
      where(:type => types, :roles => {:assignable => true}).
      uniq.
      sorted
      
      
      #manage_mega_calendar_events
  end
end
