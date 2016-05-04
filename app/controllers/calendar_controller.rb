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

  def form_holiday(holiday)
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_user') + '</td>'
    ret_var << '<td>' + holiday.user.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_start_date') + '</td>'
    ret_var << '<td>' + format_time(holiday.start) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_end_date') + '</td>'
    ret_var << '<td>' + format_time(holiday.end) + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end
  def form_issue(issue)
    custom_field_id_start = Setting.plugin_mega_calendar['custom_field_id_start']
    custom_field_id_end = Setting.plugin_mega_calendar['custom_field_id_end']
    tbegin = issue.custom_field_value(custom_field_id_start).to_s
    tend = issue.custom_field_value(custom_field_id_end).to_s
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
    ret_var << '<td>' + issue.assigned_to.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_start_date') + '</td>'
    ret_var << '<td>' + format_date(issue.start_date.to_date).to_s + ' ' + tbegin + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'field_end_date') + '</td>'
    ret_var << '<td>' + format_date(issue.due_date.to_date).to_s + ' ' + tend + ' </td>' rescue '<td></td>'
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

    holidays = Holiday.where(['((holidays.start <= ? AND holidays.end >= ?) OR (holidays.start BETWEEN ? AND ?)  OR (holidays.end BETWEEN ? AND ?))' + (fuser.blank? ? '' : ' AND holidays.user_id = ' + User.current.id.to_s),fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
    issues = Issue.where(['issues.tracker_id IN (?) AND ((issues.start_date <= ? AND issues.due_date >= ?) OR (issues.start_date BETWEEN ? AND ?)  OR (issues.due_date BETWEEN ? AND ?))' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
    issues2 = Issue.where(['issues.tracker_id IN (?) AND issues.start_date >= ? AND issues.due_date IS NULL' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fbegin.to_s]) rescue []
    issues3 = Issue.where(['issues.tracker_id IN (?) AND issues.start_date IS NULL AND issues.due_date <= ?' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),tracker_ids,fend.to_s]) rescue []
    @events = []
    def_holiday = '#' + Setting.plugin_mega_calendar['default_holiday_color']
    def_color = '#' + Setting.plugin_mega_calendar['default_event_color']

    @events = @events + holidays.collect {|h| {
        :id => h.id.to_s,
        :controller_name => 'holiday',
        :title => (h.user.blank? ? '' : h.user.to_s + ' - ') + (translate 'label_holiday'),
        :start => h.start.localtime.strftime('%Y-%m-%d %H:%M'),
        :end => h.end.localtime.strftime('%Y-%m-%d %H:%M'),
        :allDay => false,
        :borderColor => def_holiday,
        :color => '#' + h.user.custom_field_value(custom_field_id_color).to_s,
        :url => @base_url + '/holidays/show?id=' + h.id.to_s,
        :className => 'calendar_event',
        :description => form_holiday(h)
    }}
    issues = issues + issues2 + issues3
    issues = issues.compact.uniq
    issues.each do |i|
      tbegin = i.custom_field_value(custom_field_id_start).to_s
      tend = i.custom_field_value(custom_field_id_end).to_s
      css_classes = ['calendar_event']
      if !i.status.blank? && i.status.is_closed == true
        css_classes << 'calendar_event_closed'
      end
      if i.start_date.blank?
        i.start_date = i.due_date
      end
      if i.due_date.blank?
        i.due_date = i.start_date
      end

      color = '#' + i.assigned_to.custom_field_value(custom_field_id_color).to_s rescue def_color
      i_event = {
        :id => i.id.to_s,
        :controller_name => 'issue',
        :title => i.id.to_s + ' - ' + i.subject,
        :start => i.start_date.to_date.to_s + (tbegin ? ' ' + tbegin : ''),
        :end => i.due_date.to_date.to_s + (tend ? ' ' + tend : ''),
        :color => color,
        :url => @base_url + '/issues/' + i.id.to_s,
        :className => css_classes,
        :description => form_issue(i)
      }
      if tbegin.blank? || tend.blank?
        i_event[:allDay] = true
        if !i.due_date.blank? && tend.blank?
          i_event[:end] = (i.due_date + 1.day).to_date.to_s
        end
      end
      @events << i_event
    end
    render(:text => @events.to_json.html_safe)
  end
  def change_holiday
    h = Holiday.find(params[:id])
    if !params[:event_end].blank?
      h.update_attributes({:start => params[:event_begin].to_date.to_s, :end => (params[:event_end].to_date - 1.day).to_date.to_s}) rescue nil
    else
      h.update_attributes({:start => params[:event_begin].to_date.to_s, :end => params[:event_begin].to_date.to_s}) rescue nil
    end
    render(:text => "")
  end
  def change_issue
    i = Issue.find(params[:id])
    if params[:event_end].blank?
      event_end = params[:event_begin]
    else
      event_end = params[:event_end]
    end
    if !params[:event_end].include?(':')
      event_end = event_end.to_date - 1.day
    end
    i.update_attributes({:start_date => params[:event_begin].to_date.to_s, :due_date => event_end.to_date.to_s}) rescue nil
    if params[:allDay] != 'true'
      tt = TicketTime.where(:issue_id => params[:id]).first 
      if tt.blank?
        tt = TicketTime.new(:issue_id => params[:id])
      end
      tt.time_begin = params[:event_begin].to_datetime.to_s
      if !params[:event_end].blank?
        tt.time_end = params[:event_end].to_datetime.to_s rescue nil
      else
        i.update_attributes({:due_date => (params[:event_begin].to_datetime + 2.hours).to_datetime.to_s})
        tt.time_end = (params[:event_begin].to_datetime + 2.hours).to_datetime.to_s
      end
      tt.save
    else
      tt = TicketTime.where(:issue_id => params[:id]).first rescue nil
      if !tt.blank?
        tt.destroy()
      end
    end
    render(:text => "")
  end
end
