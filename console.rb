require File.expand_path(File.dirname(__FILE__)) + "/boot"

require 'active_support/all'

%w{
   /lib/analyzers/schema_guesser
  }.each do |lib|
    require File.here lib
  end

alias :x :exit
binding.pry

