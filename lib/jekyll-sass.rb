require "jekyll-sass/version"
require "colorator"

module Jekyll
  module Sass
    require 'sass'

    class SassConfig
      def self.sass_config(site)
        site.config['sass'] || {}
      end

      def self.style(site)
        sass_config = sass_config(site)
        if site.config['watch']
          style = sass_config['style'] || 'expanded'
        else
          style = sass_config['deploy_style'] ||
            sass_config['style'] ||
            'compressed'
        end
        style.to_sym
      end

      def self.line_comments(site)
        should_comment = false
        if site.config['watch'] && self.style(site).to_s == 'expanded'
          should_comment = true
        end
        should_comment
      end

      def self.compile_in_place?(site)
        sass_config(site)['compile_in_place']
      end
    end

    class SassCssFile < StaticFile
      class << self
        attr_accessor :should_write_sass
      end

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
        return false if !SassCssFile.should_write_sass

        @@mtimes[path] = mtime
        dest_path = destination(dest)
        FileUtils.mkdir_p(File.dirname(dest_path))
        begin
          engine = ::Sass::Engine.for_file(path,
                                           :style => SassConfig.style(@site),
                                           :line_comments => SassConfig.line_comments(@site))
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
        rescue ::Sass::SyntaxError => e
          STDERR.puts "Sass failed generating '#{e.sass_filename}' line:#{e.sass_line} '#{e.message}'".red
          false
        end
        true
      end
    end

    class SuppressedSassFile < StaticFile
      def update_mtime
        @@mtimes[path] = mtime
      end
    end

    class SassCssGenerator < Generator
      safe true

      # Jekyll will have already added the *.sass/scss files as Jekyll::StaticFile
      # objects to the static_files array.  Here we replace those with a
      # SassCssFile object.
      def generate(site)
        site.static_files.clone.each do |sf|
          if sf.path =~ /\.(scss|sass)$/
            site.static_files.delete(sf)
            name = File.basename(sf.path)
            destination = File.dirname(sf.path).sub(site.source, '')
            sass_file =  SassCssFile.new(site, site.source, destination, name)
            if sass_file.modified?
              SassCssFile.should_write_sass = true
            end
            site.static_files << sass_file
          end
        end
        supp_files = suppressed_sass_files(site)
        if suppressed_files_modified?(supp_files)
          SassCssFile.should_write_sass = true
          update_files_mtime(supp_files)
        end
      end

      def suppressed_files_modified?(files)
        files.each do |file|
          return true if file.modified?
        end
        return false
      end

      def update_files_mtime(files)
        files.each do |file|
          file.update_mtime
        end
      end

      def suppressed_sass_files(site)
        sass_matcher = /^_.*\.(sass|scss)/
        suppressed_sass_paths = recursively_search_directories(site, sass_matcher)
        files = [ ]
        suppressed_sass_paths.each do |path|
          name = File.basename(path)
          destination = File.dirname(path).sub(site.source, '')
          files << SuppressedSassFile.new(site, site.source, destination, name)
        end
        return files
      end

      # Recursively find files in site that match a regexp
      # Does not ignore underscored files
      # This could probably be shortened but
      # we need to search like jekyll searches
      #
      # site - The Jekyll site
      # matcher - a regexp for the filename's to find
      # dir - the relative directory to recurse in
      #
      # Returns an Array of absolute paths that match
      def recursively_search_directories(site, matcher, dir = '')
        base = File.join(site.source, dir)
        entries = Dir.chdir(base) { site.filter_entries(Dir.entries('.')) }
        found = [ ]
        entries.each do |f|
          f_abs = File.join(base, f)
          found << f_abs if matcher.match(f)
          if File.directory?(f_abs)
            f_rel = File.join(dir, f)
            if site.dest.sub(/\/$/, '') != f_abs
              more_found = recursively_search_directories(site, matcher, f_rel)
              found.concat(more_found)
            end
          end
        end
        return found
      end

    end
  end
end
