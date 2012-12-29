# http://gilesbowkett.blogspot.com/2009/04/unshiftfiledirnamefile.html
class File
  def self.here(string)
    expand_path(dirname(__FILE__)) + string
  end
end

require 'rubygems'

# http://yehudakatz.com/2011/05/30/gem-versioning-and-bundler-doing-it-right/
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require :default

