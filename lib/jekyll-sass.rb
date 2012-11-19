require "jekyll-sass/version"

module Jekyll
  module Sass
    require 'sass'
    class SassCssFile < StaticFile

      # Obtain destination path.
      #   +dest+ is the String path to the destination dir
      #
      # Returns destination file path.
      def destination(dest)
        File.join(dest, @dir, @name.sub(/scss$/, 'css'))
      end

      # Convert the scss file into a css file.
      #   +dest+ is the String path to the destination dir
      #
      # Returns false if the file was not modified since last time (no-op).
      def write(dest)
        dest_path = destination(dest)

        return false if File.exist? dest_path and !modified?
        @@mtimes[path] = mtime

        FileUtils.mkdir_p(File.dirname(dest_path))
        begin
          config = Jekyll.configuration({})
          style = config.has_key?('sass_style') ? config['sass_style'].to_sym : :compressed

          content = File.read(path)
          engine = ::Sass::Engine.new( content, :syntax => :scss, :load_paths => ["#{@site.source}#{@dir}"], :style => style )
          content = engine.render
          File.open(dest_path, 'w') do |f|
            f.write(content)
          end
        rescue => e
          STDERR.puts "Sass failed generating '#{dest_path}': #{e.message}"
          false
        end

        true
      end

    end

    class SassCssGenerator < Generator
      safe true

      # Jekyll will have already added the *.scss files as Jekyll::StaticFile
      # objects to the static_files array.  Here we replace those with a
      # SassCssFile object.
      def generate(site)
        site.static_files.clone.each do |sf|
          if sf.kind_of?(Jekyll::StaticFile) && sf.path =~ /\.scss$/
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
