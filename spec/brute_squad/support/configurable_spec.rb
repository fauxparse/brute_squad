require File.dirname(__FILE__) + '/../../spec_helper'

describe BruteSquad::Support::Configurable do
  class ConfigurableTestClass
    include BruteSquad::Support::Configurable
    
    configure :simple => "Simple"
  end
  
  describe "included in a class" do
    before :each do
      @object = ConfigurableTestClass.new
    end
    
    it "should know its option keys" do
      ConfigurableTestClass.configuration_options.keys.should == [ :simple ]
    end
    
    it "should set a simple option" do
      @object.simple.should == "Simple"
    end
  end
end