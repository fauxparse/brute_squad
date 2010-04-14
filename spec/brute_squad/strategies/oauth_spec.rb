require File.dirname(__FILE__) + '/../../spec_helper'

describe BruteSquad::Strategies::Oauth do
  before :each do
    BruteSquad.authenticates :users do
      class_name     "BruteSquad::Spec::Helpers::TestUser"
      session_secret nil # unsigned sessions for easier tests
      keys           [ :id ]
      
      authenticate_with :oauth do
        provider        "http://twitter.com"
        consumer_key    "9YaswkYKjfcAkJhrFHsqZw"
        consumer_secret "lXz9wwoD9hcYhtCEqxggmK1Unu6Qc1mOkF3qFcAow"
      end
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
        env["brute_squad"].users.attempt_login :oauth => true
        success_app.call env
      end
    end
  
    it "should redirect to the auth provider" do
      @status, @headers, @response = @rack.call @env
      @status.should == 302
      @headers["Location"].should =~ %r{^http://twitter.com/}
      puts @headers["Location"]
    end
  end
end