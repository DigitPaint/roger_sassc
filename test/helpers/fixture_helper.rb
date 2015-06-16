# Fixture helper for tests
module FixtureHelper
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../fixtures"))

  def fixture(path)
    File.read(fixture_path(path))
  end

  def fixture_path(path)
    File.join(FIXTURE_ROOT, path)
  end
end
