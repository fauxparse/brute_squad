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
            def require_#{singular};    require_(:#{singular}); end
            def logged_in_#{singular}?; logged_in?(:#{singular}); end
            def current_#{singular};    brute_squad.current_#{singular}; end
            
            protected :require_#{singular}, :current_#{singular}
            helper_method :require_#{singular}, :current_#{singular}
          EOS
        end
      end
      
    protected
      def brute_squad
        @brute_squad ||= request.env[:brute_squad]
      end
    
      def logged_in?(model = nil)
        model ||= BruteSquad.default
        model && send(:"current_#{model}").present?
      end
    
      def require_(model)
        unless logged_in?(model)
          render :text => "Not logged in!"
        end
      end
    end
  end
end
