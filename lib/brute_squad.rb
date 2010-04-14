require "rack"
require "brute_squad/support"

module BruteSquad
  extend self
  
  def models
    @models ||= ActiveSupport::OrderedHash.new
  end
  
  def authenticates(model, options = {}, &block)
    configuration_for model.to_sym, options, &block
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
  def configuration_for(model, options = {}, &block)
    if models[model]
      models[model].configure_with options, &block
    else
      models[model] = Model.new model, options, &block
    end
  end
end

require "brute_squad/strategies"
require "brute_squad/encryption"
require "brute_squad/model"
require "brute_squad/session"
require "brute_squad/enforcer"
require "brute_squad/rails" if defined? Rails

require "brute_squad/support/rack/utils"
