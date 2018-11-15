module Rhino
  class Request
    RACK_VERSION = 'rack.version'.freeze
    RACK_ERRORS = 'rack.errors'.freeze
    RACK_INPUT = 'rack.input'.freeze
    RACK_MULTIPROCESS = 'rack.multiprocess'.freeze
    RACK_MULTITHREAD = 'rack.multithread'.freeze
    RACK_RUN_ONCE = 'rack.run_once'.freeze
    RACK_URL_SCHEME = 'rack.url_scheme'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    REQUEST_URI = 'REQUEST_URI'.freeze
    HTTP_VERSION = 'HTTP_VERSION'.freeze
    QUERY_STRING = 'QUERY_STRING'.freeze
    SERVER_PORT = 'SERVER_PORT'.freeze
    SERVER_NAME = 'SERVER_NAME'.freeze
    SCRIPT_NAME = 'SCRIPT_NAME'.freeze
    PATH_INFO = 'PATH_INFO'.freeze

    DEFAULT_RACK_URL_SCHEME = 'http'.freeze

    DEFAULT_SERVER_NAME = 'localhost'.freeze
    DEFAULT_SERVER_PORT = 80

    DEFAULT_PATH_INFO = ''.freeze
    DEFAULT_QUERY_STRING = ''.freeze
    DEFAULT_SCRIPT_NAME = ''.freeze

    CONTENT_TYPE = 'CONTENT_TYPE'.freeze
    CONTENT_LENGTH = 'CONTENT_LENGTH'.freeze
    DEFAULT_CONTENT_LENGTH = 0

    REQUEST_LINE_FORMAT = /\A(?<method>\S+)\s+(?<uri>\S+)\s+(?<version>\S+)#{CRLF}\Z/.freeze
    HEADER_LINE_FORMAT = /\A(?<key>[^:]+):\s*(?<value>.+)#{CRLF}\Z/.freeze
    HEADER_LINE_FOLD_FORMAT = /\A\s+(?<fold>.+)#{CRLF}\Z/.freeze

    HEADER_LINE_FOLD_SEPARATOR = ' '.freeze

    def self.env(socket)
      request = Request.new(socket)
      request.parse
      request.env
    end

    def initialize(socket)
      @socket = socket
      @custom = {}
    end

    def parse
      parse_request_line
      loop do
        break unless parse_header_line
      end
    end

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

    def rack_input
      StringIO.new(@socket.read(@custom[CONTENT_LENGTH] || DEFAULT_CONTENT_LENGTH))
    end

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

    def parse_header_line_key_value(key, value)
      @current_header_line_value = value

      case key
      when Rack::CONTENT_TYPE then @custom[CONTENT_TYPE] = String(value)
      when Rack::CONTENT_LENGTH then @custom[CONTENT_LENGTH] = Integer(value)
      else @custom[('HTTP_' + key.tr('-', '_')).upcase] = value
      end
    end

    def parse_header_line_fold(fold)
      @current_header_line_value
        &.concat(HEADER_LINE_FOLD_SEPARATOR)
        &.concat(fold)
    end

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
