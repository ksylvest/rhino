# frozen_string_literal: true

module Rhino
  # Monitors listening sockets and dispatches accepted connections to the application.
  #
  # Usage:
  #
  #   server = Rhino::Server.new(application, sockets)
  #   server.run
  #
  class Server
    # @param application [#call] a Rack application
    # @param sockets [Array<Socket>]
    def initialize(application, sockets)
      @application = application
      @sockets = sockets
    end

    # @return [void]
    def run
      loop do
        monitor
      rescue Interrupt
        Rhino.logger.log("INTERRUPTED")
        return
      end
    end

    # @return [void]
    def monitor
      selections, = IO.select(@sockets)
      io, = selections
      handle(io)
    end

  private

    # @param connection [Socket]
    # @return [void]
    def handle(connection)
      socket, = connection.accept
      Rhino::HTTP.handle(socket, @application)
    rescue Rhino::ParseError, Errno::ECONNRESET, Errno::ENOTCONN, Errno::EPIPE, Errno::EPROTOTYPE => e
      Rhino.logger.log("EXCEPTION: #{e.message}")
    ensure
      socket.close
    end
  end
end
