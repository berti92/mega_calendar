class IssueHookMegaCalendarListener < Redmine::Hook::ViewListener
	render_on :view_issues_form_details_bottom, :partial => "issues/view_issues_form_details_bottom"
end
