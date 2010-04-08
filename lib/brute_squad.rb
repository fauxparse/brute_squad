module BruteSquad
  def self.models
    @models ||= {}
  end
  
  def self.configure(model, options = {}, &block)
    returning configuration_for(model, options) do |config|
      config.instance_eval &block if block_given?
    end
  end
  
protected
  def self.configuration_for(model, options = {})
    models[model.to_sym] ||= Model.new(model, options)
  end
end

require "brute_squad/rails"
