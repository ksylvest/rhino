require "uri"
require "rack"
require "time"

module Rhino
  class HTTP
    RESERVED = /\A(Date|Connection)\Z/i.freeze
    VERSION = "HTTP/1.1".freeze
    CRLF = "\r\n".freeze

    class Exception < ::Exception
    end

    attr_accessor :socket

    def initialize(socket)
      self.socket = socket
    end

    def parse
      rl = socket.gets
      matches = /\A(?<method>\S+)\s+(?<uri>\S+)\s+(?<version>\S+)#{CRLF}\Z/.match(rl)
      raise Exception.new("invalid request line: #{rl.inspect}") if !matches
      begin
        uri = URI.parse(matches[:uri])
      rescue URI::InvalidURIError
        raise Exception.new("invalid URI in request line: #{rl.inspect}")
      end

      env = {
        "rack.errors" => $stderr,
        "rack.input" => socket,
        "rack.version" => Rack::VERSION,
        "rack.multithread" => !!Rhino.config.multithread,
        "rack.multiprocess" => !!Rhino.config.multiprocess,
        "rack.run_once" => !!Rhino.config.run_once,
        "rack.url_scheme" => uri.scheme || "http",
        "REQUEST_METHOD" => matches[:method],
        "REQUEST_URI" => matches[:uri],
        "HTTP_VERSION" => matches[:version],
        "QUERY_STRING" => uri.query || "",
        "SERVER_PORT" => uri.port || 80,
        "SERVER_NAME" => uri.host || "localhost",
        "PATH_INFO" => uri.path || "",
        "SCRIPT_NAME" => "",
      }

      while matches = /\A(?<key>[^:]+):\s+(?<value>.*)#{CRLF}\Z/.match(line = socket.gets) do

        case matches[:key]
        when Rack::CONTENT_TYPE then env["CONTENT_TYPE"] = matches[:value]
        when Rack::CONTENT_LENGTH then env["CONTENT_LENGTH"] = Integer(matches[:value])
        else env["HTTP_" + matches[:key].tr("-", "_").upcase] ||= matches[:value]
        end
      end

      input = socket.read(env["CONTENT_LENGTH"] || 0)

      env["rack.input"] = StringIO.new(input)

      return env
    end

    def handle(application)
      env = parse
      begin
        status, headers, body = application.call(env)
      rescue => exception
        Rhino.logger.log(exception.inspect)
        status, headers, body = 500, {}, []
      end
      time = Time.now.httpdate

      socket.write "#{VERSION} #{status} #{Rack::Utils::HTTP_STATUS_CODES.fetch(status) { 'UNKNOWN' }}#{CRLF}"
      socket.write "Date: #{time}#{CRLF}"
      socket.write "Connection: close#{CRLF}"

      headers.each do |key, value|
        if !RESERVED.match(key)
          socket.write "#{key}: #{value}#{CRLF}"
        end
      end

      socket.write(CRLF)

      body.each do |chunk|
        socket.write(chunk)
      end

      Rhino.logger.log("[#{time}] '#{env["REQUEST_METHOD"]} #{env["REQUEST_URI"]} #{env["HTTP_VERSION"]}' #{status}")
    end
  end
end
