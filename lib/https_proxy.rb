#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'webrick'
require 'webrick/httpproxy'
require 'zlib'

class WEBrick::HTTPProxyServer

  def service(req, res)
    if req.request_method == "CONNECT"
      #do_CONNECT(req, res)
      puts 'HTTPS request!!'
      puts req.accept
      puts req.request_method
      puts req.unparsed_uri
      puts req.path
      puts req.query_string
      puts req.request_uri
    elsif req.unparsed_uri =~ %r!^http://!
      proxy_service(req, res)
    else
      super(req, res)
    end
  end

end


proxy = WEBrick::HTTPProxyServer.new(
  Port: 8000
  )


proxy.start

