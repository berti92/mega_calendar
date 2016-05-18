require 'redmine'

require_dependency 'issues_patch_mega_calendar'
require_dependency 'issues_hook_mega_calendar'
require_dependency 'users_hook_mega_calendar'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  Issue.send(:include, IssuePatchMegaCalendar)
end

Redmine::Plugin.register :mega_calendar do
  name 'Mega Calendar plugin'
  author 'Andreas Treubert'
  description 'Better calendar for redmine'
  version '1.3.1'
  url 'https://github.com/riccardonar/mega_calendar'
  author_url 'https://github.com/riccardonar'
  requires_redmine :version_or_higher => '3.0.1'

  project_module :mega_calendar do
    permission :view_mega_calendar, { :calendar => [:index, :form_calendar_event, :form_issue, :get_events, :change_calendar_event, :change_issue] }
    permission :manage_mega_calendar_events, { :calendar_events => [:index, :new, :show, :create, :edit, :update, :destroy] }
  end

  menu :top_menu, :calendar, { :controller => 'calendar', :action => 'index' }, :caption => :label_calendar, :if => Proc.new {
    User.current.allowed_to?(:view_mega_calendar, nil, :global => true) ||
    User.current.admin
  }
  menu :top_menu, :calendar_events, { :controller => 'calendar_event', :action => 'index' }, :caption => :label_calendar_events, :if => Proc.new {
    User.current.allowed_to?(:manage_mega_calendar_events, nil, :global => true) ||
    User.current.admin
  }

  settings :default => {
      'default_event_color' => 'D59235',
      'default_issue_color' => '4F90FF',
      'tracker_ids' => [],
      'custom_field_id_color' => '0',
      'custom_field_id_start' => '0',
      'custom_field_id_end' => '0',
      'default_calendar_view' => 'agendaWeek',
      'hidden_days_of_week' => [],
      'start_time' => '7:00',
      'end_time' => '20:00'
    }, :partial => 'settings/mega_calendar_settings'
end

