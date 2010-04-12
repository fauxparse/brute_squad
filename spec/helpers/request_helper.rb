module BruteSquad::Spec
  module Helpers
    def env_with_params(path = "/", params = {}, env = {})
      method = params.fetch(:method, "GET")
      Rack::MockRequest.env_for path,
        env.reverse_merge(
          :input => Rack::Utils.build_query(params),
          'HTTP_VERSION' => '1.1',
          'REQUEST_METHOD' => "#{method}"
        )
    end

    def setup_rack(app = nil, options = {}, &block)
      app ||= block if block_given?

      Rack::Builder.new do
        use BruteSquad::Spec::Helpers::Session
        use BruteSquad::Enforcer, options
        run app
      end
    end

    def valid_response
      Rack::Response.new("OK").finish
    end

    def success_app
      lambda{ |e| [ 200, { "Content-Type" => "text/plain" }, [ "success!" ] ] }
    end

    def failure_app
      lambda{ |e| [ 401, { "Content-Type" => "text/plain" }, [ "failure!" ] ] }
    end
    
    def parse_cookies(headers)
      returning({}) do |cookies|
        if c = headers["Set-Cookie"]
          Array(c).map { |s| s.split(';') }.flatten.each do |str|
            k, v = str.split('=')
            cookies[k.strip] = v.strip
          end
        end
      end
    end

    class Session
      attr_accessor :app
      def initialize(app,configs = {})
        @app = app
      end

      def call(e)
        e['rack.session'] ||= {}
        @app.call(e)
      end
    end
  end
end
