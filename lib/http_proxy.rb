#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'webrick'
require 'webrick/httpproxy'

handler = proc do |req, res|
  puts req.header['host']
  unless res.body.nil?
    unless res['content-type'].nil?
      #if res['content-type'].include? 'text/html' and req.header['host'].include? 'carterhay'
      if req.header['host'].include? 'carterhay'
        res.body = 'replaced'
      end
    end
  end
end

proxy = WEBrick::HTTPProxyServer.new(
  Port: 8080, 
  ProxyContentHandler: handler, 
  AccessLog: []
)

proxy.start

