module Rhino
  class Server

    def initialize(application, sockets)
      @application = application
      @sockets = sockets
    end

    def run
      loop do
        monitor
      rescue Interrupt
        Rhino.logger.log('INTERRUPTED')
        return
      end
    end

    def monitor
      selections, = IO.select(@sockets)
      io, = selections
      handle(io)
    end

  private

    def handle(connection)
      socket, = connection.accept
      Rhino::HTTP.handle(socket, @application)
    rescue Rhino::ParseError => exception # , Errno::ECONNRESET, Errno::ENOTCONN, Errno::EPIPE, Errno::EPROTOTYPE
      Rhino.logger.log("EXCEPTION: #{exception.message}")
    ensure
      socket.close
    end

  end
end
