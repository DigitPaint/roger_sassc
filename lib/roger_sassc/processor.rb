require "sassc"
require "roger/release"

require "fileutils"
require "pathname"

module RogerSassc
  # The Roger Processor for LibSass
  class Processor < ::Roger::Release::Processors::Base
    def initialize(options = {})
      @options = {
        match: ["stylesheets/**/*.scss"],
        skip: [%r{/_.*\.scss\Z}],
        load_paths: RogerSassc.load_paths
      }.update(options)
    end

    # @option options [Hash]
    #   :build_files
    def call(release, options = {})
      @release = release
      @options = @options.update(options)

      match = @options.delete(:match)
      skip = @options.delete(:skip)

      @options[:load_paths] = @options[:load_paths].map do |path|
        build_path + path
      end

      # Sassify SCSS files
      files = release.get_files(match)

      files.each do |f|
        # Doing skip by hand, so that we can clean the skipped ones
        next if skip.detect { |r| r.match(f) }

        release.log(self, "Processing: #{f}")
        # Compile SCSS
        compile_file(f)
      end

      # Remove source file
      clean_files(files)
    end

    private

    def clean_files(files)
      files.each { |f| File.unlink(f) }
    end

    def build_path
      @release.project.path
    end

    def compile_file(path)
      scss = File.read(path)

      File.open(path.gsub(/\.scss$/, ".css"), "w+") do |file|
        file.write(SassC::Engine.new(scss, @options).render)
      end
    end
  end
end
