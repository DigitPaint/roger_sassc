require "roger_sassc/version"

# The RogerSassc namespace
module RogerSassc
  DEFAULT_LOAD_PATHS = ["html/stylesheets", "bower_components"]

  class << self
    attr_accessor :load_paths

    def append_path(path)
      if load_paths.nil?
        self.load_paths = DEFAULT_LOAD_PATHS.dup
        # Legacy reasons stuff for gems etc.
        if defined?(Sass.load_paths)
          self.load_paths = load_paths + Sass.load_paths
        end
      end
      load_paths.push(path)
    end
  end

  def load_paths
    self.class.load_paths
  end
end

require "roger_sassc/middleware"
require "roger_sassc/processor"
