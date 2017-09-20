require "sassc"
require "roger/resolver"
require "rack"

module RogerSassc
  # Rack Middleware for Roger Sassc
  #
  # This middleware transforms a given url scss -> css. It does this
  # by checking if the .css can be resolved to .scss file, if so it
  # compiles (with the help of libsass) the scss.
  class Middleware
    attr_writer :resolver
    attr_accessor :project

    def initialize(app, options = {})
      @app = app

      defaults = {
        load_paths: RogerSassc.load_paths,
        source_map: true
      }

      @options = defaults.update(options)

      # If the sourcemap is embedded, the content of the source must
      # be embedded, because the paths to the sources will not be correct,
      # and the browser will not be able to load the source.
      @options[:source_map_contents] = true if @options[:source_map_embed]
    end

    def call(env)
      @project ||= env["roger.project"]
      @options[:roger_html_path] = @project.html_path

      url = ::Rack::Utils.unescape(env["PATH_INFO"].to_s).sub(%r{^/}, "")
      unless url.end_with?(".css") || url.end_with?(".css.map")
        return @app.call(env)
      end

      # Convert the url to an absolute path,
      # which is used to retrieve compile the scss
      scss_path = resolve_url(url)

      return @app.call(env) unless scss_path

      env["rack.errors"].puts "Invoking ruby-sassc for #{scss_path}"
      engine = create_scss_engine(scss_path)

      begin
        respond(engine, url.end_with?(".css.map"))
      rescue ::SassC::SyntaxError,
             ::SassC::NotRenderedError,
             ::SassC::InvalidStyleError => sassc_error
        respond_with_error(sassc_error)
      end
    end

    private

    def resolve_url(url)
      # Make sure we strip off .map
      url = url.gsub(/.map\Z/, "")

      # A .css file is requested in the browser
      url.gsub!(/\.css$/, ".scss")

      # Use the resolver to translate urls to file paths
      # returns nill when no file is found via url
      resolver.url_to_path url, exact_match: true
    end

    def create_scss_engine(scss_path)
      # Supply the filename for load path resolving
      @options[:filename] = scss_path.to_s

      # Set a sourcemap file if the sourcemap is not embedded
      if @options[:source_map] && !@options[:source_map_embed]
        @options[:source_map_file] = scss_path.to_s.gsub(/\.scss$/, ".css.map")
      end

      ::SassC::Engine.new(File.read(scss_path), @options)
    end

    def debug_css(sassc_error)
      # Replace
      # * regular line-ends with css compat strings
      #     via: http://stackoverflow.com/questions/9062988/newline-character-sequence-in-css-content-property
      # * single quotes with double quotes for escaping
      sassc_error_css_string = sassc_error.to_s.gsub("\n", "\\A").gsub("'", "\"")

      # Build debug string
      debug = "/*\n"
      debug << "#{sassc_error}\n\n"
      debug << "Load paths:\n"
      debug << "#{@options[:load_paths]}\n\n"
      debug << "*/\n"
      debug << "body:before {\n"
      debug << "  white-space: pre;\n"
      debug << "  font-family: monospace;\n"
      debug << "  content: '#{sassc_error_css_string}'; }\n"
    end

    def resolver
      @resolver ||= Roger::Resolver.new(@project.html_path)
    end

    def respond_with_error(err)
      resp = ::Rack::Response.new do |res|
        res.status = 200
        res.headers["Content-Type"] = "text/css"
        # last modified header
        res.write debug_css(err)
      end
      resp.finish
    end

    def respond(engine, map = false)
      css = engine.render

      resp = ::Rack::Response.new do |res|
        res.status = 200
        res.headers["Content-Type"] = "text/css"
        # last modified header
        res.write map ? engine.source_map : css
      end
      resp.finish
    end
  end
end
