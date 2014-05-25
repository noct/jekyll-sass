Sass for Jekyll
===============

This gem provides a [Jekyll](http://github.com/mojombo/jekyll) converter for
[Sass](http://sass-lang.com/) files.

Basic Setup
-----------
Install the gem:

	[sudo] gem install jekyll-sass
	
With Jekyll 2, simply add the gem to your `_config.yml` gems list:

	gems: [jekyll-sass]

Or for previous versions, create a plugin file within your Jekyll project's `_plugins` directory:

	# _plugins/my-plugin.rb
	require "jekyll-sass"

Place .scss files anywhere in your Jekyll project's directory.  These will be
converted to .css files with the same directory path and filename. For example,
if you create an `scss` file at `css/my-stuff/styles.scss`, then the corresponding
css file would end up at `css/my-stuff/styles.css`.

Bundler Setup
-------------
Using bundler to manage gems for your Jekyll project? Just add

	gem "jekyll-sass"

to your gemfile and create the following plugin in your projects `_plugins`
directory.  This will automatically require all of the gems specified in your Gemfile.

	# _plugins/bundler.rb
	require "rubygems"
	require "bundler/setup"
	Bundler.require(:default)

Configuration
-------------
In your `_config.yml`

	# defaults
	sass:
		style:  expanded  # nested|expanded|compact|compressed
		deploy_style: compressed  # nested|expanded|compact|compressed
		# "deploy_style:" is used only for building the site
		# (ie: not using the --watch flag)
 
		compile_in_place: false   # true|false
		# If true, compiles sass directly into your jekyll source directory
		# As well as your destination directory

Credit
------
This gem is based on [@zroger's](https://github.com/zroger) [jekyll-less](https://github.com/zroger/jekyll-less),
with contributions from [@zznq](https://github.com/zznq), [@Tambling](https://github.com/Tambling), [@rebelzach](https://github.com/rebelzach), [@kelvinst](https://github.com/kelvinst), and [@bitboxer](https://github.com/bitboxer).
