class CalendarController < ApplicationController
  unloadable
  
  before_filter :check_plugin_right

  def check_plugin_right		
    right = (User.current.allowed_to?(:view_mega_calendar, nil, :global => true) || User.current.admin)	
    if !right
      flash[:error] = translate 'no_right'		
      redirect_to({:controller => :welcome})		
    end		
  end

  def initialize
    super()

    @default_calendar_view = Setting['plugin_mega_calendar']['default_calendar_view']
    @hidden_days_of_week = Setting['plugin_mega_calendar']['hidden_days_of_week']
    @start_time = Setting['plugin_mega_calendar']['start_time']
    @end_time = Setting['plugin_mega_calendar']['end_time']
    if Rails::VERSION::MAJOR < 3
      @base_url = Redmine::Utils::relative_url_root.to_s
    else
      @base_url = config.relative_url_root.to_s
    end
  end

  def index
  end

  def form_calendar_event(calendar_event)
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_title') + '</td>'
    ret_var << '<td>' + (calendar_event.title.blank? ? ' - ' : calendar_event.title.to_s) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_user') + '</td>'
    ret_var << '<td>' + (calendar_event.user.blank? ? ' - ' : calendar_event.user.to_s) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_start_date') + '</td>'
    ret_var << '<td>' + format_time(calendar_event.start) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_end_date') + '</td>'
    ret_var << '<td>' + format_time(calendar_event.end) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end

  def form_issue(issue)
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_project') + '</td>'
    ret_var << '<td>' + issue.project.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_status') + '</td>'
    ret_var << '<td>' + issue.status.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_assigned_to') + '</td>'
    ret_var << '<td>' + issue.user.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_start_date') + '</td>'
    ret_var << '<td>' + format_time(issue.start_calendar) + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_end_date') + '</td>'
    ret_var << '<td>' + format_time(issue.end_calendar) + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end

  def get_events
    fbegin = params[:start].to_date rescue nil
    fend = params[:end].to_date rescue nil
    fuser = params[:user].to_s == 'true'
    if params[:save_values].to_s == 'true'
      session[:mega_calendar_js_user_query] = fuser
      #if fbegin.to_date == fbegin.to_date.beginning_of_month
      #  session[:mega_calendar_js_default_date] = fbegin.to_date.to_s
      #else
      #  session[:mega_calendar_js_default_date] = (fbegin.to_date.beginning_of_month + 1.month).to_s
      #end
      session[:mega_calendar_js_default_date] = fbegin.to_date.to_s
    end
    fbegin = (Date.today - 1.month) if(fbegin.blank?)
    fend = (Date.today + 1.month) if(fend.blank?)

    custom_field_id_color = Setting.plugin_mega_calendar['custom_field_id_color']
    custom_field_id_start = Setting.plugin_mega_calendar['custom_field_id_start']
    custom_field_id_end = Setting.plugin_mega_calendar['custom_field_id_end']
    tracker_ids = Setting.plugin_mega_calendar['tracker_ids']

    calendar_events = CalendarEvent.where(['((calendar_events.start <= ? AND calendar_events.end >= ?) OR (calendar_events.start BETWEEN ? AND ?) OR (calendar_events.end BETWEEN ? AND ?))' + (fuser.blank? ? '' : ' AND calendar_events.user_id = ' + User.current.id.to_s),fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
    issues = Issue.where(['issues.tracker_id IN (?) AND ((issues.start_date <= ? AND issues.due_date >= ?) OR (issues.start_date BETWEEN ? AND ?) OR (issues.due_date BETWEEN ? AND ?))' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
    issues2 = Issue.where(['issues.tracker_id IN (?) AND issues.start_date >= ? AND issues.due_date IS NULL' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fbegin.to_s]) rescue []
    issues3 = Issue.where(['issues.tracker_id IN (?) AND issues.start_date IS NULL AND issues.due_date <= ?' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fend.to_s]) rescue []
    @events = []
    def_event_color = '#' + Setting.plugin_mega_calendar['default_event_color'].to_s
    def_issue_color = '#' + Setting.plugin_mega_calendar['default_issue_color'].to_s

    @events = @events + calendar_events.collect {|h| {
        :id => h.id.to_s,
        :controller_name => 'calendar_event',
        :title => h.title.to_s + ' - ' + h.user.to_s,
        :start => h.start.localtime.strftime('%Y-%m-%d %H:%M'),
        :end => h.end.localtime.strftime('%Y-%m-%d %H:%M'),
        :allDay => false,
        :borderColor => def_event_color,
        :color => (h.user.blank? ? def_event_color : '#' + h.user.custom_field_value(custom_field_id_color).to_s),
        :url => @base_url + '/calendar_event/show?id=' + h.id.to_s,
        :className => 'calendar_event',
        :description => form_calendar_event(h)
    }}
    issues = issues + issues2 + issues3
    issues = issues.compact.uniq
    issues.each do |i|
      css_classes = ['calendar_event']
      if !i.status.blank? && i.status.is_closed == true
        css_classes << 'calendar_event_closed'
      end

      color = '#' + i.assigned_to.custom_field_value(custom_field_id_color).to_s rescue def_issue_color
      i_event = {
        :id => i.id.to_s,
        :controller_name => 'issue',
        :title => i.id.to_s + ' - ' + i.subject,
        #:start => i.start_date.to_date.to_s + (tbegin ? ' ' + tbegin.rjust(5, '0') : ''),
        #:end => i.due_date.to_date.to_s + (tend ? ' ' + tend.rjust(5, '0') : ''),
        :start => i.start_calendar.strftime('%FT%T%:z'),
        :end => i.end_calendar.strftime('%FT%T%:z'),
        :color => color,
        :url => @base_url + '/issues/' + i.id.to_s,
        :className => css_classes,
        :description => form_issue(i)
      }
      if i.start_time.blank? || i.end_time.blank?
        i_event[:allDay] = true
        if i.end_time.blank?
          i_event[:end] = (i.due_date + 1.day).to_date.to_s
        end
      end
      @events << i_event
    end
    render(:text => @events.to_json.html_safe)
  end

  def change_calendar_event
    h = CalendarEvent.find(params[:id])
    if !params[:event_end].blank?
      h.update_attributes({ :start => Time.parse(params[:event_begin]), :end => Time.parse(params[:event_end]) }) rescue nil
    else
      h.update_attributes({ :start => Time.parse(params[:event_begin]), :end => Time.parse(params[:event_begin]) }) rescue nil
    end
    render(:text => "")
  end

  def change_issue
    i = Issue.find(params[:id])
    event_begin = params[:event_begin]
    if params[:event_end].blank?
      event_end = params[:event_begin]
    else
      event_end = params[:event_end]
    end
    
    if params[:allDay] != 'true'
      custom_field_id_start = Setting.plugin_mega_calendar['custom_field_id_start']
      custom_field_id_end = Setting.plugin_mega_calendar['custom_field_id_end']

      time_begin = params[:event_begin].to_datetime.strftime('%H:%M')
      if !params[:event_end].blank?
        time_end = params[:event_end].to_datetime.strftime('%H:%M') rescue nil
      else
        time_end = params[:event_begin].to_datetime.strftime('%H:%M') rescue nil
      end
    end
    i.start_date = event_begin.to_date.to_s
    i.due_date = event_end.to_date.to_s
    i.custom_field_values = {
      custom_field_id_start => time_begin,
      custom_field_id_end => time_end
    }
    i.save!
    
    render(:text => "")
  end
end
