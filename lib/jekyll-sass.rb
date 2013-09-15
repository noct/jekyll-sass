require "jekyll-sass/version"

module Jekyll
  module Sass
    require 'sass'

    class SassConfig
      def self.syntax(site)
        (site.config['sass']['syntax'] || 'scss').to_sym
      end

      def self.style(site)
        if site.config['watch']
          style = site.config['sass']['style'] || 'expanded'
        else
          style = site.config['sass']['deploy_style'] ||
            site.config['sass']['style'] ||
            'compressed'
        end
        style.to_sym
      end

      def self.compile_in_place?(site)
        site.config['sass']['compile_in_place']
      end
    end

    class SassCssFile < StaticFile

      # Obtain destination path.
      #   +dest+ is the String path to the destination dir
      #
      # Returns destination file path.
      def destination(dest)
        File.join(dest, @dir, File.basename(@name, ".*") + ".css")
      end

      def in_place_destination(dest)
        File.join(File.dirname(path), File.basename(@name, ".*") + ".css")
      end

      # Convert the sass/scss file into a css file.
      #   +dest+ is the String path to the destination dir
      #
      # Returns false if the file was not modified since last time (no-op).
      def write(dest)
        dest_path = destination(dest)
        return false if File.exist? dest_path and !modified?
        @@mtimes[path] = mtime
        FileUtils.mkdir_p(File.dirname(dest_path))
        begin
          content = File.read(path)
          engine = ::Sass::Engine.new(content,
                                      :syntax => SassConfig.syntax(@site),
                                      :load_paths => [File.join(@site.source, @dir)],
                                      :style => SassConfig.style(@site))
          content = engine.render
          File.open(dest_path, 'w') do |f|
            f.write(content)
          end
          if SassConfig.compile_in_place?(@site)
            in_place_dest_path = in_place_destination(dest)
            File.open(in_place_dest_path, 'w') do |f|
              f.write(content)
            end
          end
        rescue Sass::SyntaxError => e
          STDERR.puts "Sass failed generating '#{dest_path}': #{e.message}"
          false
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
        syntax = SassConfig.syntax(site)
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
