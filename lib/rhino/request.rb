# frozen_string_literal: true

module Rhino
  # Parses an HTTP request (request line and headers) from a socket into a Rack env.
  #
  # Usage:
  #
  #   env = Rhino::Request.env(socket)
  #
  class Request
    RACK_VERSION = "rack.version"
    RACK_ERRORS = "rack.errors"
    RACK_INPUT = "rack.input"
    RACK_MULTIPROCESS = "rack.multiprocess"
    RACK_MULTITHREAD = "rack.multithread"
    RACK_RUN_ONCE = "rack.run_once"
    RACK_URL_SCHEME = "rack.url_scheme"
    REQUEST_METHOD = "REQUEST_METHOD"
    REQUEST_URI = "REQUEST_URI"
    HTTP_VERSION = "HTTP_VERSION"
    QUERY_STRING = "QUERY_STRING"
    SERVER_PORT = "SERVER_PORT"
    SERVER_NAME = "SERVER_NAME"
    SCRIPT_NAME = "SCRIPT_NAME"
    PATH_INFO = "PATH_INFO"

    DEFAULT_RACK_URL_SCHEME = "http"

    DEFAULT_SERVER_NAME = "localhost"
    DEFAULT_SERVER_PORT = 80

    DEFAULT_PATH_INFO = ""
    DEFAULT_QUERY_STRING = ""
    DEFAULT_SCRIPT_NAME = ""

    CONTENT_TYPE = "CONTENT_TYPE"
    CONTENT_LENGTH = "CONTENT_LENGTH"
    DEFAULT_CONTENT_LENGTH = 0

    REQUEST_LINE_FORMAT = /\A(?<method>\S+)\s+(?<uri>\S+)\s+(?<version>\S+)#{CRLF}\Z/
    HEADER_LINE_FORMAT = /\A(?<key>[^:]+):\s*(?<value>.+)#{CRLF}\Z/
    HEADER_LINE_FOLD_FORMAT = /\A\s+(?<fold>.+)#{CRLF}\Z/

    HEADER_LINE_FOLD_SEPARATOR = " "

    # @param socket [Socket]
    # @raise [Rhino::ParseError]
    # @return [Hash{String => Object}] the Rack env
    def self.env(socket)
      request = Request.new(socket)
      request.parse
      request.env
    end

    # @param socket [Socket]
    def initialize(socket)
      @socket = socket
      @custom = {}
    end

    # @raise [Rhino::ParseError]
    # @return [void]
    def parse
      parse_request_line
      loop do
        break unless parse_header_line
      end
    end

    # @return [Hash{String => Object}] the Rack env
    def env # rubocop:disable Metrics/MethodLength
      @custom.merge(
        RACK_VERSION => Rack::VERSION,
        RACK_INPUT => rack_input,
        RACK_ERRORS => $stderr,
        RACK_MULTIPROCESS => Rhino.config.multiprocess,
        RACK_MULTITHREAD => Rhino.config.multithread,
        RACK_RUN_ONCE => Rhino.config.run_once,
        HTTP_VERSION => @version,
        REQUEST_METHOD => @method,
        REQUEST_URI => String(@uri),
        RACK_URL_SCHEME => @uri.scheme || DEFAULT_RACK_URL_SCHEME,
        SERVER_PORT => @uri.port || DEFAULT_SERVER_PORT,
        SERVER_NAME => @uri.host || DEFAULT_SERVER_NAME,
        QUERY_STRING => @uri.query || DEFAULT_QUERY_STRING,
        PATH_INFO => @uri.path || DEFAULT_PATH_INFO,
        SCRIPT_NAME => DEFAULT_SCRIPT_NAME
      )
    end

  private

    # @return [StringIO]
    def rack_input
      StringIO.new(@socket.read(@custom[CONTENT_LENGTH] || DEFAULT_CONTENT_LENGTH))
    end

    # @raise [Rhino::ParseError]
    # @return [String, Integer, nil] nil once the blank line terminating the headers is read
    def parse_header_line
      raw_header_line = @socket.gets
      return if raw_header_line.eql?(CRLF)

      if (matches = HEADER_LINE_FOLD_FORMAT.match(raw_header_line))
        parse_header_line_fold(matches[:fold].strip)
      elsif (matches = HEADER_LINE_FORMAT.match(raw_header_line))
        parse_header_line_key_value(matches[:key].strip, matches[:value].strip)
      else
        raise ParseError, "invalid header line: #{raw_header_line.inspect}"
      end
    end

    # @param key [String]
    # @param value [String]
    # @return [String, Integer]
    def parse_header_line_key_value(key, value)
      @current_header_line_value = value

      case key
      when Rack::CONTENT_TYPE then @custom[CONTENT_TYPE] = String(value)
      when Rack::CONTENT_LENGTH then @custom[CONTENT_LENGTH] = Integer(value)
      else @custom["HTTP_#{key.tr('-', '_').upcase}"] = value
      end
    end

    # @param fold [String]
    # @return [String, nil]
    def parse_header_line_fold(fold)
      @current_header_line_value
        &.concat(HEADER_LINE_FOLD_SEPARATOR)
        &.concat(fold)
    end

    # @raise [Rhino::ParseError]
    # @return [void]
    def parse_request_line
      raw_request_line = @socket.gets
      matches = REQUEST_LINE_FORMAT.match(raw_request_line)
      raise ParseError, "invalid request line: #{raw_request_line.inspect}" unless matches

      @uri = URI.parse(matches[:uri])
      @method = matches[:method]
      @version = matches[:version]
    rescue URI::InvalidURIError
      raise ParseError, "invalid URI in request line: #{raw_request_line.inspect}"
    end
  end
end
