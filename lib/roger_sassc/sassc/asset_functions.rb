require "sassc"
require "base64"
require "mime/types"
require "digest"

module RogerSassc
  module SassC
    # Defintion of asset functions
    module AssetFunctions
      # The asset_path method will search for
      # the file and if it exists will append a fingerprint
      # hexdigest to the output url (?v=DIGEST)
      def asset_path(path)
        file = find_file(path)

        if File.exist?(file)
          digest = Digest::SHA256.file(file).hexdigest
          finger_printed_path = "#{path.value}?v=#{digest}"
        else
          finger_printed_path = path.value
        end

        ::SassC::Script::String.new("url(#{finger_printed_path})", :identifier)
      end

      def inline_base64(path)
        file = find_file(path)

        if File.exist?(file)
          encoded_file = Base64.encode64(File.open(file, "rb").read)
          mime_type = MIME::Types.type_for(File.basename(file)).first
          base64_string = "data:#{mime_type};base64,#{encoded_file}"
        else
          base64_string = path.value
        end

        ::SassC::Script::String.new("url(\"#{base64_string}\")", :identifier)
      end

      private

      # Translate the given path to a path on disk
      def find_file(path)
        # Absolute url, starting with /
        if path.value.match(%r{^\/[^\/]})
          File.join(@options[:roger_html_path], path.value)
        else
          # Relative url - we can join from .scss position
          File.join(File.dirname(@options[:filename]), path.value)
        end
      end
    end
  end
end

# SassC includes ruby functions for us
module ::SassC::Script::Functions
  include ::RogerSassc::SassC::AssetFunctions
end
