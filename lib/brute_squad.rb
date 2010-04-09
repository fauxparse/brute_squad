require "brute_squad/support"

module BruteSquad
  extend self
  
  def models
    @models ||= ActiveSupport::OrderedHash.new
  end
  
  def authenticates(model, options = {}, &block)
    returning configuration_for(model, options) do |config|
      config.instance_eval &block if block_given?
    end
  end
  
  def authenticates?(model)
    models[model.to_sym].present?
  end
  
  def [](model)
    configuration_for model.to_sym
  end
  
  def each(&block)
    models.each &block
  end
  
  def default
    nil
  end
  
protected
  def configuration_for(model, options = {})
    (models[model.to_sym] ||= Model.new(model)).configure_with(options)
  end
end

require "brute_squad/strategies"
require "brute_squad/model"
require "brute_squad/enforcer"
require "brute_squad/middleware"
require "brute_squad/rails" if defined? Rails
