require File.dirname(__FILE__) + '/../spec_helper'

describe BruteSquad::Enforcer do
  before :each do
    BruteSquad.authenticates :users do
      class_name     "BruteSquad::Spec::Helpers::TestUser"
      session_secret nil # unsigned sessions
      keys           [ :id ]
    end
    
    @user = TestUser.new :name => "Test", :id => 1
  end
  
  it "should insert a session object for each model" do
    env = env_with_params
    setup_rack(success_app).call(env)
    env["brute_squad.users"].should be_an_instance_of(BruteSquad::Session)
  end
end