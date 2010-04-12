require File.dirname(__FILE__) + '/../../spec_helper'

describe BruteSquad::Strategies::Password do
  before :each do
    BruteSquad.authenticates :users do
      class_name     "BruteSquad::Spec::Helpers::TestUser"
      session_secret nil # unsigned sessions for easier tests
      retrieval_keys [ :id ]
      
      authenticate_with :password
    end
    
    @user = TestUser.new :name => "Test", :id => 1, :email => "test@example.com"
  end

  it "should pass the current user in" do
    env = env_with_params "/", {}, { 'HTTP_COOKIE' => 'brute_squad.users.session="BAh7BjoHaWRJIgYxBjoNZW5jb2RpbmciClVURi04";' }
    setup_rack(success_app).call(env)
    env["brute_squad.users"].current.should == @user
  end
  
  describe "with HTTP basic auth" do
    before :each do |variable|
      @env = env_with_params "/", {}, { 'HTTP_AUTHORIZATION' => 'Basic dGVzdEBleGFtcGxlLmNvbTpwYXNzd29yZA==' }
    end
    
    it "should allow login" do
      setup_rack(success_app).call(@env)
      @env["brute_squad.users"].current.should == @user
    end

    it "should not persist login" do
      s, h, r = setup_rack(success_app).call(@env)
      h['Set-Cookie'].should_not be_present
    end
    
    describe "turned off" do
      before :each do
        BruteSquad.authenticates :users do
          authenticate_with :password do
            allow_basic false
            allow_basic.should == false
          end
        end
      end

      it "should not allow login" do
        setup_rack(success_app).call(@env)
        @env["brute_squad.users"].should_not be_logged_in
      end
    end
  end
end