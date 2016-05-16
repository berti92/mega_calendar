module IssuePatchMegaCalendar
  def self.included(base)
	base.send(:include, InstanceMethods)
	base.class_eval do 
	  unloadable
	  before_save :save_due_date
	end
  end

  module InstanceMethods

    def respect_filters_mega_calendar
      trackers = Setting.plugin_mega_calendar['tracker_ids'].map{|id| id.to_i}
      return trackers.include? (self.tracker_id )
    end

    def start_time
      custom_field_id = Setting.plugin_mega_calendar['custom_field_id_start']
      return self.custom_field_value(custom_field_id).to_s
    end

    def end_time
      custom_field_id = Setting.plugin_mega_calendar['custom_field_id_end']
      return self.custom_field_value(custom_field_id).to_s
    end

    def start_calendar
      return Time.parse(self.start_date.to_date.to_s + ' ' + self.start_time)
    end

    def end_calendar
      if self.due_date.blank?
        self.due_date = self.start_date
      end
      return Time.parse(self.due_date.to_date.to_s + ' ' + self.end_time)
    end

    def save_due_date
      if self.due_date.blank?
        self.due_date = self.start_date
      end
    end
  end
end
