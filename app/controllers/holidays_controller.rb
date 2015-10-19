class HolidaysController < ApplicationController
  unloadable

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
    holiday = Holiday.new(params[:holiday])
    if holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => holiday.id)
    else
      render(:action => :new)
    end
  end

  def edit
    @holiday = Holiday.where(:id => params[:id]).first rescue nil
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def update
    holiday = Holiday.where(:id => params[:id]).first rescue nil
    holiday.attributes(params[:holiday])
    if holiday.save
      redirect_to(:controller => 'holidays', :action => 'show', :id => holiday.id)
    else
      render(:action => :edit)
    end
  end

  def destroy
    holiday = Holiday.where(:id => params[:id]).first rescue nil
    holiday.destroy()
    redirect_to(:controller => 'holidays', :action => 'index')
  end
end
