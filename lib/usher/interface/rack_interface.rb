$:.unshift File.dirname(__FILE__)

require 'rack_interface/route'

class Usher
  module Interface
    class RackInterface
      
      RequestMethods = [:method, :host, :port, :scheme]
      Request = Struct.new(:path, *RequestMethods)
      
      def initialize
        @routes = Usher.new(:request_methods => RequestMethods)
      end
      
      def add(path, options = {})
        @routes.add_route(path, options)
      end

      def reset!
        @routes.reset!
      end

      def call(env)
        response = @routes.recognize(Request.new(env['REQUEST_URI'], env['REQUEST_METHOD'].downcase, env['HTTP_HOST'], env['SERVER_PORT'].to_i, env['rack.url_scheme']))
        env['usher.params'] = response.params.inject({}){|h,(k,v)| h[k]=v; h }
        response.path.route.params.first.call(env)
      end

    end
  end
end