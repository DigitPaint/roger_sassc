require "test_helper"
require "fileutils"
require "./lib/roger_sassc/processor"

module RogerSassc
  # Test the processor
  class TestProcessor < ::Test::Unit::TestCase
    include FixtureHelper

    TEST_OUTPUT = "../../tmp/test/fixtures/"

    def setup
      @processor = Processor.new {}
      @processor.stubs(:build_path).returns("./")

      # Copy fixtures files to fixtures/out
      output_path = fixture_path(TEST_OUTPUT)
      FileUtils.rm_rf output_path
      FileUtils.mkdir_p output_path
      FileUtils.cp_r fixture_path("."), output_path
    end

    def test_processor_can_be_called
      assert_respond_to(@processor, :call)
    end

    # Meh :(
    def test_call_processor
      files = [
        fixture_path(TEST_OUTPUT + "general.scss"),
        fixture_path(TEST_OUTPUT + "src/_variables.scss")
      ]

      release = release_mock(files)
      expected_css = fixture "output.css"
      @processor.call release

      # File is created
      assert_path_exist fixture_path(TEST_OUTPUT + "general.css")

      # And matches earlier output
      assert_equal fixture(TEST_OUTPUT + "general.css"), expected_css

      # Check clean up
      assert_path_not_exist files[0]
      assert_path_not_exist files[1]
    end

    def test_processor_raises_on_compilation_errors
      files = [
        fixture_path(TEST_OUTPUT + "raise.scss")
      ]

      release = release_mock(files)

      assert_raise SassC::SyntaxError do
        @processor.call release
      end
    end

    private

    def release_mock(files)
      release = mock(get_files: files,
                     log: ->(_s, _m) {})

      release
    end
  end
end
