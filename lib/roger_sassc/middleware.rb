require "sassc"
require "roger/resolver"
require "rack"

module RogerSassc
  # Rack Middleware for Roger sass
  class Middleware
    def initialize(app, options = {})
      @app = app
      defaults = {
        load_paths: RogerSassc.load_paths
      }

      @options = defaults.update(options)
    end

    def call(env)
      url = ::Rack::Utils.unescape(env["PATH_INFO"].to_s).sub(%r{^/}, "")

      if url.end_with?(".css") && scss_path = resolve_url(url)
        # Convert the url to an absolute path,
        # which is used to retrieve the asset from sprockets
        css = compile_scss(scss_path)
        respond(css)
      else
        @app.call(env)
      end
    end

    private

    def resolve_url(url)
      url = url[0..-4] + "scss"
      # Use the resolver to translate urls to file paths
      # returns nill when no file is found via url
      resolver = Roger::Resolver.new(@app.project.html_path)
      resolver.url_to_path url, exact_match: true
    end

    def compile_scss(scss_path)
      engine = SassC::Engine.new(File.read(scss_path), @options)
      engine.render
    end

    def respond(css)
      resp = ::Rack::Response.new do |res|
        res.status = 200
        res.headers["Content-Type"] = "text/css"
        # last modified header
        res.write css
      end
      resp.finish
    end
  end
end
