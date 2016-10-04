module Rhino

  # Handles the bootstrapping of the application (setting up sockets, building via rack, etc).
  #
  # Usage:
  #
  #   launcher = Rhino.Launcher.new(5000, '0.0.0.0', reuseaddr, 64, './config.ru')
  #   launcher.run
  #
  class Launcher
    attr_accessor :port
    attr_accessor :bind
    attr_accessor :backlog
    attr_accessor :config
    attr_accessor :reuseaddr

    def initialize(port, bind, reuseaddr, backlog, config)
      self.port = port
      self.bind = bind
      self.reuseaddr = reuseaddr
      self.backlog = backlog
      self.config = config
    end

    def run
      Rhino.logger.log("Rhino")
      Rhino.logger.log("#{bind}:#{port}")

      begin
        socket = Socket.new(:INET, :STREAM)
        socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, reuseaddr)
        socket.bind(Addrinfo.tcp(self.bind, self.port))
        socket.listen(self.backlog)

        server = Rhino::Server.new(application, [socket])
        server.run
      ensure
        socket.close
      end
    end

  private

    def application
      raw = File.read(self.config)
      builder = <<~BUILDER
      Rack::Builder.new do
        #{raw}
      end
      BUILDER
      @application ||= eval(builder, nil, self.config)
    end

  end

end
