require File.dirname(__FILE__) + '/../../spec_helper'

describe BruteSquad::Strategies::Password do
  before :each do
    BruteSquad.authenticates :users do
      class_name     "BruteSquad::Spec::Helpers::TestUser"
      session_secret nil # unsigned sessions for easier tests
      keys           [ :id ]
      
      authenticate_with :password
    end
    
    @user = TestUser.new :name => "Test", :id => 1, :email => "test@example.com"
  end

  it "should pass the current user in" do
    env = env_with_params "/", {}, { 'HTTP_COOKIE' => 'brute_squad.users.session=BAh7BjoMY3VycmVudHsGOgdpZCIGMQ==;' }
    setup_rack(success_app).call(env)
    env["brute_squad"].users.current.should == @user
  end
  
  describe "logging in from the app" do
    before :each do
      @env = env_with_params
      @rack = setup_rack do |env|
        env["brute_squad"].users.attempt_login :email => "test@example.com", :password => "password"
        success_app.call env
      end
    end
    
    it "should allow logins" do
      @rack.call @env
      @env["brute_squad"].users.current.should == @user
    end
    
    it "should set a valid cookie" do
      s, h, r = @rack.call @env
      cookies = parse_cookies(h)
      cookies["brute_squad.users.session"].should be_present
      
      env = env_with_params "/", {}, { 'HTTP_COOKIE' => "brute_squad.users.session=#{cookies["brute_squad.users.session"]};" }
      setup_rack(success_app).call(env)
      env["brute_squad"].users.current.should == @user
    end
    
    describe "and logging out again" do
      before :each do
        s, h, r = @rack.call @env
        cookies = parse_cookies(h)
        @env = env_with_params "/", {}, { 'HTTP_COOKIE' => "brute_squad.users.session=#{cookies["brute_squad.users.session"]};" }
        @rack = setup_rack do |env|
          env["brute_squad"].users.log_out_and_redirect! "/login"
          success_app.call env
        end
        
        @status, @headers, @response = @rack.call(@env)
      end
      
      it "should delete the cookie" do
        cookies = parse_cookies(@headers)
      end
      
      it "should redirect to another URL" do
        @status.to_i.should == 302
        @headers["Location"].should == "/login"
      end
      
      it "should send a proper message" do
        @response.first.should == "You have been logged out."
      end
    end
  end
  
  describe "with HTTP basic auth" do
    before :each do |variable|
      @env = env_with_params "/", {}, { 'HTTP_AUTHORIZATION' => 'Basic dGVzdEBleGFtcGxlLmNvbTpwYXNzd29yZA==' }
    end
    
    it "should allow login" do
      setup_rack(success_app).call(@env)
      @env["brute_squad"].users.current.should == @user
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
          end
        end
      end

      it "should not allow login" do
        setup_rack(success_app).call(@env)
        @env["brute_squad"].users.should_not be_logged_in
      end
    end
  end
end