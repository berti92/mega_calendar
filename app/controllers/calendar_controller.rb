class CalendarController < ApplicationController

  unloadable
  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token
  
# Redmine 1.3 and prior use accept_key_auth to enforce auth 
  # via the key we hand to the applet.
  if Redmine::VERSION::MAJOR == 1 and Redmine::VERSION::MINOR <= 3 then
    accept_key_auth :check_plugin_right, :export
  else
    accept_api_auth :check_plugin_right, :export
  end
  
  before_filter(:check_plugin_right)
  
  def check_plugin_right
    right = (!Setting.plugin_mega_calendar['allowed_users'].blank? && Setting.plugin_mega_calendar['allowed_users'].include?(User.current.id.to_s) ? true : false)
    if !right
      flash[:error] = translate 'no_right'
      redirect_to({:controller => :welcome})
    end
  end

  def export
    ical = Vpim::Icalendar.create({ 'METHOD' => 'REQUEST', 'CHARSET' => 'UTF-8' })
    time_start = params['time_start']
    time_end = params['time_end']
    issues = Issue.includes(:status).where("(issues.start_date IS NOT NULL OR issues.due_date IS NOT NULL)")
    issues = issues.where(:issue_statuses => {:is_closed => false})
    if time_start and time_end
        issues = issues.where(["(issues.start_date <= ? AND issues.due_date >= ?)", time_end, time_start])
    elsif time_start and not time_end
	issues = issues.where(["(issues.due_date >= ?)", time_start])
    elsif not time_start and time_end
	issues = issues.where(["(issues.start_date <= ?)", time_end])
    end
    if params['onlyassigned'] and params['onlyassigned'] == 'true'
	issues = issues.where(:assigned_to_id => User.current.id)
    end

      issues.each do |issue|
      ical.add_event do |e|
        ticket_time = TicketTime.where({:issue_id => issue.id}).first rescue nil
        tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
        tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
        if issue.start_date.blank?
          issue.start_date = issue.due_date
        end
        if issue.due_date.blank?
          issue.due_date = issue.start_date
        end
        time_start = issue.start_date.to_date.to_s + tbegin
        time_end = issue.due_date.to_date.to_s + tend
        if tbegin.blank? || tend.blank?
          if !issue.due_date.blank? && tend.blank?
            time_end = (issue.due_date + 1.day).to_date.to_s
          end
        end
        time_start = Time.parse(time_start)
        time_end = Time.parse(time_end)
        e.summary(issue.id.to_s + ' - ' + issue.subject + ' - ' + (issue.assigned_to.blank? ? '' : issue.assigned_to.firstname + " " + issue.assigned_to.lastname))
        e.dtstart(time_start)
        e.dtend(time_end)
        e.dtstamp(issue.updated_on)
        e.lastmod(issue.updated_on)
        e.created(issue.created_on)
        e.uid("RedmineMegaCalendarIssueID:"+issue.id.to_s)
        #e.sequence(seq.to_i)
        if (issue.description)
           e.description(issue.description.gsub("\n\n",""))
        end
        #if !issue.assigned_to.blank?
        #  e.organizer do |o|
        #    o.cn = issue.assigned_to.firstname + " " + issue.assigned_to.lastname
        #    o.uri = "mailto:#{issue.assigned_to.email_address.address}" rescue nil
        #  end
        #end
      end
    end
    send_data ical.encode(), filename: 'Redmine_calendar.ics'
  end

  def index
    #DO NOTHING
  end

  def form_holiday(holiday)
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'user') + '</td>'
    ret_var << '<td>' + holiday.user.login + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'start') + '</td>'
    ret_var << '<td>' + holiday.start.to_date.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'end') + '</td>'
    ret_var << '<td>' + holiday.end.to_date.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end
  def form_issue(issue)
    ticket_time = TicketTime.where({:issue_id => issue.id}).first rescue nil
    tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
    tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'project') + '</td>'
    ret_var << '<td>' + issue.project.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'status') + '</td>'
    ret_var << '<td>' + issue.status.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'user') + '</td>'
    ret_var << '<td>' + issue.assigned_to.login + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'start') + '</td>'
    ret_var << '<td>' + issue.start_date.to_date.to_s + ' ' + tbegin + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'end') + '</td>'
    ret_var << '<td>' + issue.due_date.to_date.to_s + ' ' + tend + ' </td>' rescue '<td></td>'
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
      if fbegin.to_date == fbegin.to_date.beginning_of_month
        session[:mega_calendar_js_default_date] = fbegin.to_date.to_s
      else
        session[:mega_calendar_js_default_date] = (fbegin.to_date.beginning_of_month + 1.month).to_s
      end
    end
    fbegin = (Time.zone.today - 1.month) if(fbegin.blank?)
    fend = (Time.zone.today + 1.month) if(fend.blank?)
    if fuser.blank?
      holidays = Holiday.where(['((holidays.start <= ? AND holidays.end >= ?) OR (holidays.start BETWEEN ? AND ?)  OR (holidays.end BETWEEN ? AND ?))',fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
      issues = Issue.where(['((issues.start_date <= ? AND issues.due_date >= ?) OR (issues.start_date BETWEEN ? AND ?)  OR (issues.due_date BETWEEN ? AND ?))',fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s]) rescue []
      issues2 = Issue.where(['issues.start_date >= ? AND issues.due_date IS NULL',fbegin.to_s]) rescue []
      issues3 = Issue.where(['issues.start_date IS NULL AND issues.due_date <= ?',fend.to_s]) rescue []
    else
      holidays = Holiday.where(['((holidays.start <= ? AND holidays.end >= ?) OR (holidays.start BETWEEN ? AND ?)  OR (holidays.end BETWEEN ? AND ?)) AND holidays.user_id = ?',fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,User.current.id.to_s]) rescue []
      issues = Issue.where(['((issues.start_date <= ? AND issues.due_date >= ?) OR (issues.start_date BETWEEN ? AND ?)  OR (issues.due_date BETWEEN ? AND ?)) AND issues.assigned_to_id = ?',fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,fbegin.to_s,fend.to_s,User.current.id.to_s]) rescue []
      issues2 = Issue.where(['issues.start_date >= ? AND issues.due_date IS NULL AND issues.assigned_to_id = ?',fbegin.to_s,User.current.id.to_s]) rescue []
      issues3 = Issue.where(['issues.start_date IS NULL AND issues.due_date <= ? AND issues.assigned_to_id = ?',fend.to_s,User.current.id.to_s]) rescue []
    end
    @events = []
    def_holiday = '#' + Setting.plugin_mega_calendar['default_holiday_color']
    def_color = '#' + Setting.plugin_mega_calendar['default_event_color']
    @events = @events + holidays.collect {|h| {:id => h.id.to_s, :controller_name => 'holiday', :title => (h.user.blank? ? '' : h.user.login + ' - ') + (translate 'holiday'), :start => h.start.to_date.to_s, :end => (h.end + 1.day).to_date.to_s, :allDay => true, :color => def_holiday, :url => Setting.plugin_mega_calendar['sub_path'] + 'holidays/show?id=' + h.id.to_s, :className => 'calendar_event', :description => form_holiday(h) }}
    issues = issues + issues2 + issues3
    issues = issues.compact.uniq
    issues.each do |i|
      ticket_time = TicketTime.where({:issue_id => i.id}).first rescue nil
      tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
      tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
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
      color = '#' + UserColor.where({:user_id => i.assigned_to_id}).first.color_code rescue def_color
      i_event = {:id => i.id.to_s, :controller_name => 'issue', :title => i.id.to_s + ' - ' + i.subject, :start => i.start_date.to_date.to_s + tbegin, :end => i.due_date.to_date.to_s + tend, :color => color, :url => Setting.plugin_mega_calendar['sub_path'] + 'issues/' + i.id.to_s, :className => css_classes, :description => form_issue(i) }
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
