#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'webrick'
require 'webrick/httpproxy'
require 'webrick/https'
require 'openssl'
require 'zlib'

def unzip(body)
  Zlib::GzipReader.new(StringIO.new(body), :encoding => 'ASCII-8BIT').read
end

handler = proc do |req, res|
  puts req
  if res['content-encoding'] == 'gzip'
    #puts unzip(res.body)
  end
  #puts res.header['host']
  unless res.body.nil?
    puts res['content-type']
    unless res['content-type'].nil?
      if res['content-type'].include? 'text/html'
        res['content-encoding'] = ''
        res.body = File.read('payload.html')
        res['content-length'] = res.body.bytesize
      end
      #if res['content-type'].include? 'text/html' and req.header['host'].include? 'carterhay'
      #if req.header['host'].include? 'carterhay'
      #  res.body = 'replaced'
      #end
    end
  end
end

class Proxy < WEBrick::HTTPProxyServer
  def do_CONNECT(req, res)
    #req['host'] = 'localhost'
    #res = nil
  end
end


proxy = Proxy.new(
  Port: 8080, 
  ProxyContentHandler: handler, 
  AccessLog: []
)

proxy.start

