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
      selections, = IO.select(self.sockets)
      io, = selections

      begin
        socket, = io.accept
        http = Rhino::HTTP::new(socket, application)
        http.handle
      rescue Rhino::HTTP::Exception => exception
        Rhino.logger.log("EXCEPTION: #{exception.message}")
      rescue ::Errno::ECONNRESET
      rescue ::Errno::ENOTCONN
      rescue ::Errno::EPIPE
      rescue ::Errno::EPROTOTYPE
      ensure
        socket.close
      end
    end

  end
end
