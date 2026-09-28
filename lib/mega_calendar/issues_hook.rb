module MegaCalendar
  class IssuesHook < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'issues/mega_calendar_times'
    render_on :view_issues_show_details_bottom, :partial => 'issues/mega_calendar_show_times'
  end
end
