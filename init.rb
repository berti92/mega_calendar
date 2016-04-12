require 'redmine'

require 'users_controller_patch'
require 'issues_controller_patch'

Redmine::Plugin.register :mega_calendar do
  name 'Mega Calendar plugin'
  author 'Andreas Treubert'
  description 'Better calendar for redmine'
  version '1.3.1'
  url 'https://github.com/berti92/mega_calendar'
  author_url 'https://github.com/berti92'
  requires_redmine :version_or_higher => '3.0.1'

  project_module :mega_calendar do
    permission :view_mega_calendar, { :calendar => [:index, :form_holiday, :form_issue, :get_events, :change_holiday, :change_issue] }
    permission :manage_mega_calendar_holidays, { :holidays => [:index, :new, :show, :create, :edit, :update, :destroy] }
  end

  menu :top_menu, :calendar, { :controller => 'calendar', :action => 'index' }, :caption => :calendar, :if => Proc.new {
    User.current.allowed_to?(:view_mega_calendar, nil, :global => true) ||
    User.current.admin
  }
  menu :top_menu, :holidays, { :controller => 'holidays', :action => 'index' }, :caption => :holidays, :if => Proc.new {
    User.current.allowed_to?(:manage_mega_calendar_holidays, nil, :global => true) ||
    User.current.admin
  }

  Rails.configuration.to_prepare do 
    IssuesController.send(:include, IssuesControllerPatch)
    UsersController.send(:include, UsersControllerPatch)
  end

  settings :default => { 'default_holiday_color' => 'D59235', 'default_event_color' => '4F90FF', 'sub_path' => '/' }, :partial => 'settings/mega_calendar_settings'
end
