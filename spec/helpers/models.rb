module BruteSquad::Spec
  module Helpers
    class TestUser
      attr_reader :name, :id, :email
      
      def initialize(params = {})
        params.each do |k, v|
          instance_variable_set :"@#{k}", v
        end
        self.class.instances << self
      end
      
      def self.instances
        @instances ||= []
      end
      
      def self.first(params = {})
        instances.detect do |instance|
          params.inject(true) do |valid, (k, v)|
            instance.send(k).to_s == v.to_s
          end
        end
      end
    end
  end
end