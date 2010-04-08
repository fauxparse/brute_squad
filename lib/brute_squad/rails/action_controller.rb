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
            def require_#{singular}; require_(:#{singular}); end
            def current_#{singular}; require_(:#{singular}); end
            
            protected :require_#{singular}, :current_#{singular}
            helper_method :require_#{singular}, :current_#{singular}
          EOS
        end
      end
      
    protected
      def logged_in?(model = nil)
        model ||= BruteSquad.default
        model && current_(model.to_sym).present?
      end
    
      def require_(model)
        unless logged_in?(model)
          render :text => "Not logged in!"
        end
      end
      
      def current_(model)
        nil
      end
    end
  end
end
