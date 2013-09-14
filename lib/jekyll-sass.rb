require "jekyll-sass/version"

module Jekyll
  module Sass
    require 'sass'

    class SassConfig
      def self.generate()
        config = Hash["style", :compressed, "syntax", :scss]
        if Jekyll.configuration({}).has_key?('sass')
          config.merge!(Jekyll.configuration({})['sass']) {|key,v1,v2| v2.to_sym}
        end
        config
      end

      def self.get()
        @config ||= generate()
      end
    end

    class SassCssFile < StaticFile

      # Obtain destination path.
      #   +dest+ is the String path to the destination dir
      #
      # Returns destination file path.
      def destination(dest)
        syntax = SassConfig.get()['syntax'].to_s
        File.join(dest, @dir, @name.sub(/#{syntax}$/, 'css'))
      end

      def in_place_destination(dest)
        File.join(File.dirname(path), File.basename(@name, ".*") + ".css")
      end

      # Convert the sass/scss file into a css file.
      #   +dest+ is the String path to the destination dir
      #
      # Returns false if the file was not modified since last time (no-op).
      def write(dest)
        config = SassConfig.get()
        dest_path = destination(dest)
        return false if File.exist? dest_path and !modified?
        @@mtimes[path] = mtime
        FileUtils.mkdir_p(File.dirname(dest_path))
        begin
          content = File.read(path)
          engine = ::Sass::Engine.new( content, :syntax => config['syntax'], :load_paths => ["#{@site.source}#{@dir}"], :style => config['style'] )
          content = engine.render
          File.open(dest_path, 'w') do |f|
            f.write(content)
          end
        rescue => e
          STDERR.puts "Sass failed generating '#{dest_path}': #{e.message}"
          false
        end
        if config['compile_in_place']
          begin
            in_place_dest_path = in_place_destination(dest)
            File.open(in_place_dest_path, 'w') do |f|
              f.write(content)
            end
          rescue => e
            STDERR.puts "Sass failed to write in place '#{in_place_dest_path}': #{e.message}"
            false
          end
        end
        true
      end

    end

    class SassCssGenerator < Generator
      safe true

      # Jekyll will have already added the *.sass/scss files as Jekyll::StaticFile
      # objects to the static_files array.  Here we replace those with a
      # SassCssFile object.
      def generate(site)
        syntax = SassConfig.get()['syntax'].to_s
        site.static_files.clone.each do |sf|
          if sf.path =~ /\.#{syntax}$/
            site.static_files.delete(sf)
            name = File.basename(sf.path)
            destination = File.dirname(sf.path).sub(site.source, '')
            site.static_files << SassCssFile.new(site, site.source, destination, name)
          end
        end
      end
    end
  end
end
