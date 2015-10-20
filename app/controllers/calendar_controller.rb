class CalendarController < ApplicationController
  unloadable

  def index
    #DO NOTHING
  end
  def get_events
    fbegin = params[:start].to_date rescue nil
    fend = params[:end].to_date rescue nil
    fuser = eval(params[:user].to_s) rescue false
    fbegin = (Date.today - 1.month) if(fbegin.blank?)
    fend = (Date.today + 1.month) if(fend.blank?)
    holidays = Holiday.where(['holidays.start >= ? AND holidays.end <= ?' + (fuser.blank? ? '' : ' AND holidays.user_id = ' + User.current.id.to_s),fbegin.to_s, fend.to_s]) rescue []
    issues = Issue.where(['issues.start_date >= ? AND issues.due_date <= ?' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),fbegin.to_s, fend.to_s]) rescue []
    @events = []
    def_holiday = '#' + Setting.plugin_mega_calendar['default_holiday_color']
    def_color = '#' + Setting.plugin_mega_calendar['default_event_color']
    @events = @events + holidays.collect {|h| {:title => h.user.login + ' - ' + (translate 'holiday'), :start => h.start.to_date.to_s, :end => h.end.to_date.to_s, :allDay => true, :color => def_holiday, :url => '/holidays/show?id=' + h.id.to_s, :className => 'calendar_event' }}
    issues.each do |i|
      ticket_time = TicketTime.where({:issue_id => i.id}).first rescue nil
      tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
      tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
      color = '#' + UserColor.where({:user_id => i.assigned_to_id}).first.color_code rescue def_color
      @events << {:title => i.id.to_s + ' - ' + i.subject, :start => i.start_date.to_date.to_s + tbegin, :end => i.due_date.to_date.to_s + tend, :color => color, :url => '/issues/' + i.id.to_s, :className => 'calendar_event' }
    end
    render(:text => @events.to_json.html_safe)
  end
end
