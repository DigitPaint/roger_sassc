require "test_helper"
require "sassc"
require "./lib/roger_sassc/sassc/asset_functions"

module RogerSassc
  # Test for AssetFunctions module
  class TestAssetFunctions < ::Test::Unit::TestCase
    def test_asset_path_fingerprinting_non_existing_file
      scss_path = "test/fixtures/asset_functions/asset_path_non_existing.scss"
      engine = get_engine_for(scss_path)

      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  background-image: url(./images/logo.svg); }
      EXPECTED_SCSS
    end

    def test_asset_path_fingerprinting_relative_path
      scss_path = "test/fixtures/asset_functions/asset_path_relative_path.scss"
      engine = get_engine_for(scss_path)
      # rubocop:disable LineLength
      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  background-image: url(../images/logo.svg?v=73001d8781487200a29e7d3602b59d2770060934fbd738bfdcd2bc06a2861464); }
      EXPECTED_SCSS
      # rubocop:enable LineLength
    end

    def test_asset_path_asset_fingerprinting_http_path
      scss_path = "test/fixtures/asset_functions/asset_path_http_path.scss"
      engine = get_engine_for(scss_path)

      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  background-image: url(http://google.com/images/logo.svg); }
      EXPECTED_SCSS
    end

    def test_asset_path_fingerprinting_absolute_path
      scss_path = "test/fixtures/asset_functions/asset_path_absolute_path.scss"
      engine = get_engine_for(scss_path)

      # rubocop:disable LineLength
      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  background-image: url(/images/logo.svg?v=73001d8781487200a29e7d3602b59d2770060934fbd738bfdcd2bc06a2861464); }
      EXPECTED_SCSS
      # rubocop:enable LineLength
    end

    def test_inline_base_absolute_path
      scss_path = "test/fixtures/asset_functions/inline_base_absolute_path.scss"
      engine = get_engine_for(scss_path)

      assert_match 'background-image: url("data:image/svg+xml;base64,', engine.render
    end

    private

    def get_engine_for(scss_path)
      options = {}
      options[:roger_html_path] = Pathname.new("test/fixtures").expand_path
      options[:filename] = scss_path.to_s
      ::SassC::Engine.new(File.read(scss_path), options)
    end
  end
end
