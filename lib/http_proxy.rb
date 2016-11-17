#!/usr/bin/ruby
#
# Copyright 2016 Carter Hay

require 'net/http'
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
  puts req.request_line
  unless res.body.nil?
    unless res['content-type'].nil?
      if res['content-type'].include? 'text/html'
        config.each do |conf|
          if Regexp.new(conf['regex']) =~ req.request_line
            if conf['type'] == 'replacement'
              res.body = File.read("../payloads/#{conf['file']}")
            else
              # Unzip to allow editing response body
              if res['content-encoding'] == 'gzip'
                res.body = unzip(res.body)
                res['content-encoding'] = ''
              end
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


HopByHop = %w( connection keep-alive proxy-authenticate upgrade
      proxy-authorization te trailers transfer-encoding )
ShouldNotTransfer = %w( set-cookie proxy-connection )

def split_field(f) f ? f.split(/,\s+/).collect{|i| i.downcase } : [] end

def choose_header(src, dst)
  connections = split_field(src['connection'])
  src.each{|key, value|
    key = key.downcase
      if HopByHop.member?(key)          || # RFC2616: 13.5.1
        connections.member?(key)       || # RFC2616: 14.10
          ShouldNotTransfer.member?(key)    # pragmatics
          next
          end
          dst[key] = value
  }
end


def set_cookie(src, dst)
  if str = src['set-cookie']
  cookies = []
  str.split(/,\s*/).each{|token|
    if /^[^=]+;/o =~ token
      cookies[-1] << ", " << token
        elsif /=/o =~ token
        cookies << token
    else
      cookies[-1] << ", " << token
        end
  }
dst.cookies.replace(cookies)
  end
  end

proxy.mount_proc '/' do |req, res|
  if req.request_method == 'GET'
    http = Net::HTTP.new req.host, 80, 'localhost', 8000
    uri = URI(req.request_uri)

    new_res = http.request (Net::HTTP::Get.new  uri, initheader = {'accept-encoding' => ''})
    res.status = new_res.code.to_i
    choose_header new_res, res
    set_cookie new_res, res
    res.body = new_res.body
    res['content-length'] = res.body.bytesize
  end 
end

proxy.start

trap 'INT' do proxy.shutdown end
