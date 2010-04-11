module BruteSquad::Spec
  module Helpers
    SUCCESS_APP = lambda{ |e| [ 200, { "Content-Type" => "text/plain" }, [ "success!" ] ] }
    FAILURE_APP = lambda{ |e| [ 401, { "Content-Type" => "text/plain" }, [ "failure!" ] ] }

    def env_with_params(path = "/", params = {}, env = {})
      method = params.fetch(:method, "GET")
      Rack::MockRequest.env_for path,
        env.reverse_merge(
          :input => Rack::Utils.build_query(params),
          'HTTP_VERSION' => '1.1',
          'REQUEST_METHOD' => "#{method}"
        )
    end

    def setup_rack(app = nil, opts = {}, &block)
      app ||= block if block_given?

      opts[:failure_app]         ||= failure_app

      Rack::Builder.new do
        use BruteSquad::Spec::Helpers::Session
        use BruteSquad::Enforcer, opts
        run app
      end
    end

    def valid_response
      Rack::Response.new("OK").finish
    end

    def success_app
      BruteSquad::Spec::Helpers::FAILURE_APP
    end

    def failure_app
      BruteSquad::Spec::Helpers::SUCCESS_APP
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
