require "test_helper"
require "roger/testing/mock_project"

require "./lib/roger_sassc/middleware"

module RogerSassc
  # Testing the middleware functionality
  # which transforms on a request based .scss to .css
  class TestMiddleware < ::Test::Unit::TestCase
    include FixtureHelper

    def setup
      setup_app(source_map: false)
    end

    def teardown
      @middleware.project.destroy
    end

    def setup_app(options = {})
      @app =  proc { [200, {}, ["YAM"]] } # Yet another middleware
      @middleware = Middleware.new @app, options

      # Inject mock project
      @middleware.project = Roger::Testing::MockProject.new

      # Avoid side-effect of cwd dir of test_construct
      @middleware.project.construct.revert_cwd

      @request = Rack::MockRequest.new(@middleware)
    end

    def test_middleware_can_be_called
      assert(@middleware.respond_to?(:call))
    end

    def test_calls_rest_of_stack_when_not_css
      assert_equal @request.get("/my.js").body, "YAM"
    end

    def test_doesn_t_compile_scss_when_no_scss_file
      @middleware.resolver = mock_resolver("not-excisting.scss", nil)
      assert_equal @request.get("/not-excisting.css").body, "YAM"
    end

    def test_respons_with_css
      path = fixture_path "general.scss"
      expected_css = fixture "output.css"
      @middleware.resolver = mock_resolver("test/fixtures/general.scss", path)
      assert_equal expected_css, @request.get("/test/fixtures/general.css").body
    end

    def test_response_with_source_map
      setup_app(source_map: true)

      path = fixture_path "general.scss"
      expected_css = fixture "output.css.map"
      @middleware.resolver = mock_resolver("test/fixtures/general.scss", path)
      assert_equal expected_css, @request.get("/test/fixtures/general.css.map").body
    end

    def test_inline_source_map
      setup_app(source_map: true, source_map_embed: true)

      path = fixture_path "general.scss"
      expected_css = fixture "output_with_map.css"
      @middleware.resolver = mock_resolver("test/fixtures/general.scss", path)
      assert_equal expected_css, @request.get("/test/fixtures/general.css").body
    end

    def test_debug_syntax_error
      path = fixture_path "errors/syntax.scss"
      expected_css = fixture "errors/syntax.css"
      @middleware.resolver = mock_resolver("test/fixtures/errors/syntax.scss", path)
      assert_equal expected_css, @request.get("test/fixtures/errors/syntax.css").body
    end

    def test_debug_import_error
      path = fixture_path "errors/import.scss"
      expected_css = '@import "trololo";'
      @middleware.resolver = mock_resolver("test/fixtures/errors/import.scss", path)
      assert_include @request.get("test/fixtures/errors/import.css").body, expected_css
    end

    private

    def mock_resolver(input_url, file_path)
      resolver = mock
      resolver.expects(:url_to_path).with(equals(input_url), anything).returns(file_path)
      resolver
    end
  end
end
