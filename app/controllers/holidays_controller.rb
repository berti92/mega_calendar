class HolidaysController < ApplicationController
  unloadable
  
  before_filter :check_plugin_right

  def check_plugin_right		
    right = (User.current.allowed_to?(:view_mega_calendar, nil, :global => true) || User.current.allowed_to?(:manage_mega_calendar_holidays, nil, :global => true) || User.current.admin)	
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
    @res = Holiday.limit(limit).offset(offset)
    @pagination = (Holiday.count.to_f / 20.to_f) > 1.to_f
  end

  def new
    #DO NOTHING
  end

  def show
    @holiday = Holiday.where(:id => params[:id]).first rescue nil
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def create
    @holiday = Holiday.new(params[:holiday])
    time_start = Time.parse(params[:holiday][:start])
    time_end = Time.parse(params[:holiday][:end])
    @holiday.start = time_start
    @holiday.end = time_end
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => @holiday.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def edit
    @holiday = Holiday.find(params[:id]) rescue nil
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def update
    @holiday = Holiday.find(params[:holiday][:id]) rescue nil
    @holiday.assign_attributes(params[:holiday])
    time_start = Time.parse(params[:holiday][:start])
    time_end = Time.parse(params[:holiday][:end])
    @holiday.start = time_start
    @holiday.end = time_end
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => @holiday.id)
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def destroy
    holiday = Holiday.where(:id => params[:id]).first rescue nil
    holiday.destroy()
    redirect_to(:controller => 'holidays', :action => 'index')
  end
end
