require 'sass/plugin/rack'
require 'rack/coffee'

require './adserver.rb'

### ---- http://andrew-stewart.ca/2012/10/26/sinatra-coffeescript-sass
# use scss for stylesheets
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

# use coffeescript for javascript
use Rack::Coffee, root: 'public', urls: '/scripts'
### ----

map '/' do
  run AdServer
end