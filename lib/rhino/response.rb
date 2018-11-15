module Rhino
  class Response
    RESERVED = /\A(Date|Connection)\Z/i.freeze
    VERSION = 'HTTP/1.1'.freeze

    def self.flush(socket, status, headers, body, time)
      new(socket, status, headers, body, time).flush
    end

    def initialize(socket, status, headers, body, time)
      @socket = socket
      @status = status
      @headers = headers
      @body = body
      @time = time
    end

    def flush
      @socket.write "#{VERSION} #{@status} #{summary}#{CRLF}"
      @socket.write "Date: #{@time}#{CRLF}"
      @socket.write "Connection: close#{CRLF}"

      @headers.each do |key, value|
        @socket.write "#{key}: #{value}#{CRLF}" unless RESERVED.match?(key)
      end

      @socket.write(CRLF)

      @body.each do |chunk|
        @socket.write(chunk)
      end
    end

  private

    def summary
      Rack::Utils::HTTP_STATUS_CODES.fetch(@status) { 'UNKNOWN' }
    end
  end
end
