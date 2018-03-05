module Rhino

  # Handles the bootstrapping of the application (setting up sockets, building via rack, etc).
  #
  # Usage:
  #
  #   launcher = Rhino.Launcher.new(5000, '0.0.0.0', reuseaddr, 64, './config.ru')
  #   launcher.run
  #
  class Launcher
    def initialize(port, bind, reuseaddr, backlog, config)
      @port = port
      @bind = bind
      @reuseaddr = reuseaddr
      @backlog = backlog
      @config = config
    end

    def run
      Rhino.logger.log('Rhino')
      Rhino.logger.log("#{@bind}:#{@port}")

      @socket = Socket.new(:INET, :STREAM)
      @socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, @reuseaddr)
      @socket.bind(Addrinfo.tcp(@bind, @port))
      @socket.listen(@backlog)

      Rhino::Server.new(application, [@socket]).run
    ensure
      @socket.close
    end

    def application
      @application ||= eval(builder, nil, @config) # rubocop:disable Security/Eval
    end

  private

    def builder
      <<~BUILDER
        Rack::Builder.new do
          #{File.read(@config)}
        end
      BUILDER
    end

  end

end
