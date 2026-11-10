# frozen_string_literal: true

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

    # @param socket [Socket]
    # @param application [#call] a Rack application
    # @return [void]
    def self.handle(socket, application)
      new(socket, application).handle
    end

    # @param socket [Socket]
    # @param application [#call] a Rack application
    def initialize(socket, application)
      @socket = socket
      @application = application
    end

    # @return [void]
    def handle
      env = Request.env(@socket)
      status, headers, body = process(env)
      time = Time.now.httpdate
      Response.flush(@socket, status, headers, body, time)

      Rhino.logger.log("[#{time}] '#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} #{env['HTTP_VERSION']}' #{status}")
    end

  private

    # @param env [Hash{String => Object}] the Rack env
    # @return [Array(Integer, Hash{String => String}, #each)] the Rack status, headers, and body
    def process(env)
      @application.call(env)
    rescue ::Exception => e # rubocop:disable Lint/RescueException
      Rhino.logger.log(e.inspect)
      EXCEPTION_TUPLE
    end
  end
end
