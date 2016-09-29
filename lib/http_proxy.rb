#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'socket'
require 'uri'

class HttpProxy
  def start
    @socket = TCPServer.new 8000



end
