require 'redmine'

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

  menu :top_menu, :calendar, { :controller => 'calendar', :action => 'index' }, :caption => :label_calendar, :if => Proc.new {
    User.current.allowed_to?(:view_mega_calendar, nil, :global => true) ||
    User.current.admin
  }
  menu :top_menu, :holidays, { :controller => 'holidays', :action => 'index' }, :caption => :label_holidays, :if => Proc.new {
    User.current.allowed_to?(:manage_mega_calendar_holidays, nil, :global => true) ||
    User.current.admin
  }

  settings :default => {
      'default_holiday_color' => 'D59235',
      'default_event_color' => '4F90FF',
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
