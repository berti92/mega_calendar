class CalendarEventController < ApplicationController
  unloadable
  
  before_filter :check_plugin_right

  def check_plugin_right		
    right = (User.current.allowed_to?(:view_mega_calendar, nil, :global => true) || User.current.allowed_to?(:manage_mega_calendar_calendar_events, nil, :global => true) || User.current.admin)	
    if !right
      flash[:error] = translate 'no_right'		
      redirect_to({:controller => :welcome})		
    end		
  end
  
  def initialize
    super()

    if Rails::VERSION::MAJOR < 3
      @base_url = Redmine::Utils::relative_url_root.to_s
    else
      @base_url = config.relative_url_root.to_s
    end
  end

  def index
    limit = 20
    offset = 0
    @new_page = 1
    @last_page = 0
    if !params[:page].blank? && params[:page].to_i >= 1
      offset = params[:page].to_i * limit
      @new_page = params[:page].to_i + 1
      @last_page = params[:page].to_i - 1
    end
    @res = CalendarEvent.limit(limit).offset(offset)
    @pagination = (CalendarEvent.count.to_f / 20.to_f) > 1.to_f
  end

  def new
    @calendar_event = CalendarEvent.new
  end

  def show
    @calendar_event = CalendarEvent.where(:id => params[:id]).first rescue nil
    if @calendar_event.blank?
      redirect_to(:controller => 'calendar_event', :action => 'index')
    end
  end

  def create
    @calendar_event = CalendarEvent.new
    @calendar_event.assign_attributes(params[:calendar_event])
    time_start = Time.parse(params[:calendar_event][:start])
    time_end = Time.parse(params[:calendar_event][:end])
    @calendar_event.start = time_start
    @calendar_event.end = time_end
    @calendar_event.title = params[:calendar_event][:title]
    if @calendar_event.save
      redirect_to(:controller => 'calendar_event', :action => 'show', :id => @calendar_event.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@calendar_event) }
      end
    end
  end

  def edit
    @calendar_event = CalendarEvent.find(params[:id]) rescue nil
    if @calendar_event.blank?
      redirect_to(:controller => 'calendar_event', :action => 'index')
    end
  end

  def update
    @calendar_event = CalendarEvent.find(params[:id]) rescue nil
    @calendar_event.assign_attributes(params[:calendar_event])
    time_start = Time.parse(params[:calendar_event][:start])
    time_end = Time.parse(params[:calendar_event][:end])
    @calendar_event.start = time_start
    @calendar_event.end = time_end
    @calendar_event.title = params[:calendar_event][:title]
    if @calendar_event.save
      redirect_to(:controller => 'calendar_event', :action => 'show', :id => @calendar_event.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@calendar_event) }
      end
    end
  end

  def destroy
    calendar_event = CalendarEvent.where(:id => params[:id]).first rescue nil
    calendar_event.destroy()
    redirect_to(:controller => 'calendar_event', :action => 'index')
  end
end
