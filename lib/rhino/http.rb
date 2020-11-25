module Rhino

  # An interface for HTTP. Responsible for reading and writting to the socket via the HTTP protocol.
  #
  # Usage:
  #
  #   http = Rhino::HTTP.new(socket, application)
  #   http.handle
  #
  class HTTP

    EXCEPTION_STATUS = 500
    EXCEPTION_HEADERS = {}.freeze
    EXCEPTION_BODY = [].freeze

    EXCEPTION_TUPLE = [EXCEPTION_STATUS, EXCEPTION_HEADERS, EXCEPTION_BODY].freeze

    def self.handle(socket, application)
      new(socket, application).handle
    end

    def initialize(socket, application)
      @socket = socket
      @application = application
    end

    def handle
      env = Request.env(@socket)
      status, headers, body = process(env)
      time = Time.now.httpdate
      Response.flush(@socket, status, headers, body, time)

      Rhino.logger.log("[#{time}] '#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} #{env['HTTP_VERSION']}' #{status}")
    end

  private

    def process(env)
      @application.call(env)
    rescue ::Exception => e # rubocop:disable Lint/RescueException
      Rhino.logger.log(e.inspect)
      EXCEPTION_TUPLE
    end
  end
end
