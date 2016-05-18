class UserHookMegaCalendarListener < Redmine::Hook::ViewListener
	render_on :view_users_form, :partial => "users/view_users_form"
end
