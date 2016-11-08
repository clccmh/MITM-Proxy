#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'webrick'
require 'webrick/httpproxy'
require 'zlib'

class WEBrick::HTTPRequest

  attr_accessor :header, :request_method, :unparsed_uri, :request_uri

  def set_request_method(method)
    @request_method = method
  end

  def set_unparsed_uri(uri)
    @unparsed_uri = uri
  end
  
end

class WEBrick::HTTPProxyServer

  def service(req, res)
    if req.request_method == "CONNECT"
      #do_CONNECT(req, res)
      #puts req.accept
      #puts req.request_method
      #puts req.unparsed_uri
      #puts req.path
      #puts req.query_string
      #puts req.request_uri
      #puts '------------------------------------'
      req.request_method = 'GET'
      req.unparsed_uri = 'carterhay.net:80'
      puts req.header[:host][0]

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

