module Sinatra
  module Authorization
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
      session[:authorized] = false
    end

    def require_authorize!
      redirect "/login?to=#{escape(request.env["REQUEST_PATH"])}" unless authorized?
    end

  end

end
