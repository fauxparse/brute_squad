require File.dirname(__FILE__) + '/../spec_helper'

describe BruteSquad::Enforcer do
  before :each do
    BruteSquad.authenticates :users do
      class_name    "BruteSquad::Spec::Helpers::TestUser"
    end
    
    @user = TestUser.new :name => "Test", :id => 1
  end
  
  it "should insert a session object for each model" do
    env = env_with_params
    setup_rack(success_app).call(env)
    env["brute_squad.users"].should be_an_instance_of(BruteSquad::Session)
  end
  
  it "should pass the current user in" do
    env = env_with_params "/", {}, { 'HTTP_COOKIE' => 'brute_squad.users.id=1;' }
    setup_rack(success_app).call(env)
    env["brute_squad.users"].current.should == @user
  end
  
  describe "with a very simple strategy" do
    before :each do
      BruteSquad.authenticates :users do
        authenticates_with :test_strategy
      end
    end
  end
end