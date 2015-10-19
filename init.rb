require 'issues_controller_patch.rb'
require 'users_controller_patch.rb'

Redmine::Plugin.register :mega_calendar do
  name 'Mega Calendar plugin'
  author 'Andreas Treubert'
  description 'Better calendar for redmine'
  version '0.0.1'
  url 'https://github.com/berti92/mega_calendar'
  author_url 'https://github.com/berti92'
  menu :top_menu, :calendar, { :controller => 'calendar', :action => 'index' }, :caption => :calendar
  menu :top_menu, :holidays, { :controller => 'holidays', :action => 'index' }, :caption => :holidays
  Rails.configuration.to_prepare do 
    IssuesController.send(:include, IssuesControllerPatch)
    UsersController.send(:include, UsersControllerPatch)
  end
  settings :default => {'default_holiday_color' => 'D59235', 'default_event_color' => '4F90FF'}, :partial => 'settings/mega_calendar_settings'
end
