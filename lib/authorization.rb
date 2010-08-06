module Sinatra
  module Authorization
    
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end
    
    def unauthorized!(realm = 'Short URL Generator')
      headers['WWW-Authenticate'] = %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end
    
    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end
    
    def authorized?
      request.env['REMOTE_USER']
    end
    
    def require_admin
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end
    
    def authorize(username, password)
      Bar.email == username && Bar.password == password
    end
  end
end