require_dependency 'users_controller'
module MegaCalendar
  module UsersControllerPatch
    def create
      super
      unless @user.id.blank?
        UserColor.create({:user_id => @user.id, :color_code => params[:user][:color], :text_color_code => params[:user][:text_color]})
      end
    end
    def update
      super
      unless @user.id.blank?
        uc = UserColor.where({:user_id => @user.id}).first rescue nil
        if uc.blank?
          uc = UserColor.new({:user_id => @user.id})
        end
        uc.color_code = params[:user][:color]
        uc.text_color_code = params[:user][:text_color]
        uc.save
      end
    end
  end
end
