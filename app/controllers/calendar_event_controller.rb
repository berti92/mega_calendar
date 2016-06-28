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
    @limit = 20
    @offset = 0

    @res_count = CalendarEvent.count

    if Redmine::VERSION.to_s > '2.5'
      @res_pages = Paginator.new(@res_count, @limit, params[:page])
      @offset = @res_pages.offset
    else
      @res_pages = Paginator.new(self, @res_count, @limit, params[:page])
      @offset = @res_pages.current.offset
    end

    @res = CalendarEvent.order(end: :desc).limit(@limit).offset(@offset)
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
