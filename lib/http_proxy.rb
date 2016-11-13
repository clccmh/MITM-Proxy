#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'webrick'
require 'webrick/httpproxy'
require 'zlib'
require_relative 'config'

config = Config.read
puts config

def unzip(body)
  Zlib::GzipReader.new(StringIO.new(body), :encoding => 'ASCII-8BIT').read
end

handler = proc do |req, res|
  # Unzip to allow editing response body
  if res['content-encoding'] == 'gzip'
    res.body = unzip(res.body)
    res['content-encoding'] = ''
  end

  puts req.request_line
  unless res.body.nil?
    unless res['content-type'].nil?
      if res['content-type'].include? 'text/html'
        config.each do |conf|
          if Regexp.new(conf['regex']) =~ req.request_line
            if conf['type'] == 'replacement'
              res.body = File.read("../payloads/#{conf['file']}")
            else
              res.body << File.read("../payloads/#{conf['file']}")
            end
            res['content-length'] = res.body.bytesize
          end
        end
      end
    end
  end
end


proxy = WEBrick::HTTPProxyServer.new(
  Port: ARGV[0], 
  ProxyContentHandler: handler, 
  AccessLog: []
)

proxy.start

