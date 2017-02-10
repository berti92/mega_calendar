require_dependency 'issues_controller'
module MegaCalendar
  module IssuesControllerPatch
    def self.included(base)
      base.class_eval do
        # Insert overrides here, for example:
        def create_with_plugin
          create_without_plugin
          if !@issue.id.blank?
            if !params[:issue][:start_date].blank? && !params[:issue][:due_date].blank? && !params[:issue][:time_begin].blank? && !params[:issue][:time_end].blank?
              tbegin = params[:issue][:start_date] + ' ' + params[:issue][:time_begin]
              tend = params[:issue][:due_date] + ' ' + params[:issue][:time_end]
              TicketTime.create({:issue_id => @issue.id, :time_begin => tbegin, :time_end => tend}) rescue nil
            end
          end
        end
        def update_with_plugin
          update_without_plugin
          if !@issue.id.blank?
            if !params[:issue][:start_date].blank? && !params[:issue][:due_date].blank? && !params[:issue][:time_begin].blank? && !params[:issue][:time_end].blank?
              tbegin = params[:issue][:start_date] + ' ' + params[:issue][:time_begin]
              tend = params[:issue][:due_date] + ' ' + params[:issue][:time_end]
              tt = TicketTime.where({:issue_id => @issue.id}).first rescue nil
              if tt.blank?
                tt = TicketTime.new({:issue_id => @issue.id})
              end
              tt.time_begin = tbegin
              tt.time_end = tend
              tt.save
            end
          end
        end
        alias_method_chain :update, :plugin
        alias_method_chain :create, :plugin # This tells Redmine to allow me to extend show by letting me call it via "show_without_plugin" above.
        # I can outright override it by just calling it "def show", at which case the original controller's method will be overridden instead of extended.
      end
    end
  end
end

MegaCalendar::IssuesControllerPatch.tap do |mod|
  IssuesController.send :include, mod unless IssuesController.include?(mod)
end
