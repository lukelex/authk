module Middlewares
  class Janus
    def initialize(app)
      @app = app
    end

    def call(env)
      auth_data = auth_for env

      if auth_data[:auth][:public_key] == 'missing'
        return Rack::Response.new({ errors: ['Not Found'] }, 404)
      end

      current_api = Actions::AuthenticateApp.new(auth_data).call do
        return Rack::Response.new({ errors: ['Unauthorized'] }, 401)
      end

      env['current_api'] = current_api

      @app.call env
    end

    private

    def auth_for(env)
      @auth_data ||= {
        verb: verb(env),
        auth: auth_keys(env),
        query_string: params_string(env)
      }
    end

    def verb(env)
      env.fetch 'REQUEST_METHOD'
    end

    def params_string(env)
      Rack::Request.new(env).params.to_query
    end

    def auth_keys(env)
      headers = headers_on env
      {
        hash: headers.fetch('X_REQUEST_HASH') { 'missing' },
        timestamp: headers.fetch('X_REQUEST_TIMESTAMP') { 'missing' },
        public_key: headers.fetch('X_ACCESS_TOKEN') { 'missing' }
      }
    end

    def headers_on(env)
      pairs = env
        .select { |k,v| k.start_with? 'HTTP_' }
        .map { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
      Hash[pairs]
    end
  end
end
