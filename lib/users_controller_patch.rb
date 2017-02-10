require_dependency 'users_controller'
module MegaCalendar
  module UsersControllerPatch
    def self.included(base)
      base.class_eval do
        # Insert overrides here, for example:
        def create_with_plugin
          create_without_plugin
          if !@user.id.blank?
            UserColor.create({:user_id => @user.id, :color_code => params[:user][:color]})
          end
        end
        def update_with_plugin
          update_without_plugin
          if !@user.id.blank?
            uc = UserColor.where({:user_id => @user.id}).first rescue nil
            if uc.blank?
              uc = UserColor.new({:user_id => @user.id})
            end
            uc.color_code = params[:user][:color]
            uc.save
          end
        end
        alias_method_chain :update, :plugin
        alias_method_chain :create, :plugin # This tells Redmine to allow me to extend show by letting me call it via "show_without_plugin" above.
        # I can outright override it by just calling it "def show", at which case the original controller's method will be overridden instead of extended.
      end
    end
  end
end

MegaCalendar::UsersControllerPatch.tap do |mod|
  UsersController.send :include, mod unless UsersController.include?(mod)
end
