require File.dirname(__FILE__) + '/../../spec_helper'

describe BruteSquad::Support::Configurable do
  class ConfigurableTestClass
    include BruteSquad::Support::Configurable
    
    configure :simple, :default => "Simple"
    configure :complex => lambda { "#{simple} is not enough" }
    configure :ike, :mike, :default => "We think alike"
    configure(:with_block) { "I am a fish" }
  end
  
  class ConfigurableTestClass2 < ConfigurableTestClass
    configure :child_only => "Ha ha"
  end
  
  describe "included in a class" do
    before :each do
      @object = ConfigurableTestClass.new
    end
    
    it "should order its option keys" do
      ConfigurableTestClass.configuration_options.keys.should == [ :simple, :complex, :ike, :mike, :with_block ]
    end
    
    it "should set a simple option" do
      @object.simple.should == "Simple"
    end
    
    it "should use a Proc for a complex option" do
      @object.complex.should == "Simple is not enough"
    end
    
    it "should allow multiple options per line" do
      @object.ike.should  == "We think alike"
      @object.mike.should == "We think alike"
    end
    
    it "should take a block at declaration time" do
      @object.with_block.should == "I am a fish"
    end
    
    it "should be able to set its defaults" do
      @object.send(:instance_variable_get, :"@simple").should be_nil
      @object.set_defaults!
      @object.send(:instance_variable_get, :"@simple").should == "Simple"
    end
    
    describe "and inherited" do
      before :each do
        @child = ConfigurableTestClass2.new
      end
      
      it "should inherit the parent's options" do
        ConfigurableTestClass2.configuration_options.keys.should == ConfigurableTestClass.configuration_options.keys + [ :child_only ]
      end
      
      it "should handle the parent's options OK" do
        @child.simple.should == "Simple"
      end
      
      it "should handle its own options OK" do
        @child.child_only.should == "Ha ha"
      end
    end
  end
end