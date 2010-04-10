module BruteSquad
  module Rails
    module ActionControllerExtensions
      def self.included(controller)
        controller.extend ClassMethods
        BruteSquad.models.each do |name, model|
          controller.define_filters_and_callbacks_for model
        end
        
        controller.helper_method :logged_in?
      end
      
      module ClassMethods
        def define_filters_and_callbacks_for(model)
          singular = model.singular
          class_eval <<-EOS
            def #{singular}_session
              @brute_squad_#{singular}_session ||= request.env["brute_squad.#{singular}.session"]
            end
            def require_#{singular};    require_(:#{singular}); end
            def logged_in_#{singular}?; logged_in?(:#{singular}); end
            def current_#{singular};    #{singular}_session.current; end
            
            protected :#{singular}_session, :require_#{singular},
                      :current_#{singular}, :logged_in_#{singular}?
            helper_method :require_#{singular}, :current_#{singular}, :logged_in_#{singular}?
          EOS
        end
      end
      
    protected
      def brute_squad
        @brute_squad_session ||= request.env[:brute_squad_session]
      end
    
      def logged_in?(model = nil)
        model ||= BruteSquad.default
        model && send(:"logged_in_#{model.singular}?")
      end
    
      def require_(model)
        unless logged_in?(model)
          render :text => "Not logged in!"
        end
      end
    end
  end
end
