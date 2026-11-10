# frozen_string_literal: true

module Rhino
  # Writes an HTTP response (status line, headers, and body) to a socket.
  #
  # Usage:
  #
  #   Rhino::Response.flush(socket, status, headers, body, time)
  #
  class Response
    RESERVED = /\A(Date|Connection)\Z/i
    VERSION = "HTTP/1.1"

    # @param socket [Socket]
    # @param status [Integer]
    # @param headers [Hash{String => String}]
    # @param body [#each]
    # @param time [String]
    # @return [void]
    def self.flush(socket, status, headers, body, time)
      new(socket, status, headers, body, time).flush
    end

    # @param socket [Socket]
    # @param status [Integer]
    # @param headers [Hash{String => String}]
    # @param body [#each]
    # @param time [String]
    def initialize(socket, status, headers, body, time)
      @socket = socket
      @status = status
      @headers = headers
      @body = body
      @time = time
    end

    # @return [void]
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

    # @return [String]
    def summary
      Rack::Utils::HTTP_STATUS_CODES.fetch(@status, "UNKNOWN")
    end
  end
end
