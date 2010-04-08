require File.dirname(__FILE__) + '/../spec_helper'

describe BruteSquad::Model do
  before :each do
    BruteSquad.models.clear
  end
  
  describe "created with defaults" do
    before :each do
      @model = BruteSquad.configure(:users)
    end

    it "should have sensible values" do
      @model.name.should == :users
      @model.singular.should == :user
      @model.class_name.should == "User"
    end
    
    it "should be listed in BruteSquad.models" do
      BruteSquad.models.should == { :users => @model }
    end
  end
  
  describe "created with options" do
    it "should accept the :singular option" do
      @model = BruteSquad.configure(:users, :singular => :person)
      @model.name.should == :users
      @model.singular.should == :person
      @model.class_name.should == "Person"
    end

    it "should accept the :class_name option" do
      @model = BruteSquad.configure(:users, :class_name => "Person")
      @model.name.should == :users
      @model.singular.should == :user
      @model.class_name.should == "Person"
    end
  end
  
  describe "created with a configuration block" do
    it "should accept the :singular option" do
      BruteSquad.configure :users do
        singular :person
      end
      @model = BruteSquad.models[:users]
      @model.name.should == :users
      @model.singular.should == :person
      @model.class_name.should == "Person"
    end

    it "should accept the :class_name option" do
      BruteSquad.configure :users do
        class_name "Person"
      end
      @model = BruteSquad.models[:users]
      @model.name.should == :users
      @model.singular.should == :user
      @model.class_name.should == "Person"
    end
  end
end