require 'socket'

module Rhino
  class Server
    attr_accessor :application
    attr_accessor :sockets

    def initialize(application, sockets)
      self.application = application
      self.sockets = sockets
    end

    def run
      loop do
        begin
          monitor
        rescue Interrupt
          Rhino.logger.log("INTERRUPTED")
          return
        end
      end
    end

    def monitor
      selections, _, _ = IO.select(self.sockets)
      io, _ = selections

      begin
        socket, _ = io.accept
        http = Rhino::HTTP::new(socket)
        http.handle(application)
      rescue ::Errno::ECONNRESET , ::Errno::ENOTCONN
      rescue::Exception => exception
        Rhino.logger.log("EXCEPTION: #{exception.message}")
      ensure
        socket.close
      end
    end

  end
end
