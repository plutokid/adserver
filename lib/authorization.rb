module Sinatra
  module Authorization
    module Helpers
      def authorized?
        session[:authorized]
      end

      def authorize(username, password)
        if [username, password] == [settings.username, settings.password]
          session[:authorized] = true
        else
          session[:authorized] = false
        end
      end

      def logout!
        session.clear
      end

      def require_authorize!
        login_path = '/login' + (request.env["REQUEST_PATH"] ? "?to=#{unescape(request.env["REQUEST_PATH"])}" : '')
        redirect login_path unless authorized?
      end
    end

    def self.registered(app)
      app.helpers Authorization::Helpers
    end
  end

  register Authorization
end
