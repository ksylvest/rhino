# frozen_string_literal: true

module Rhino
  # Handles the bootstrapping of the application (setting up sockets, building via rack, etc).
  #
  # Usage:
  #
  #   launcher = Rhino.Launcher.new(5000, '0.0.0.0', reuseaddr, 64, './config.ru')
  #   launcher.run
  #
  class Launcher
    # @param port [Integer]
    # @param bind [String]
    # @param reuseaddr [Boolean]
    # @param backlog [Integer]
    # @param config [String] the path to a rackup file (e.g. './config.ru')
    def initialize(port, bind, reuseaddr, backlog, config)
      @port = port
      @bind = bind
      @reuseaddr = reuseaddr
      @backlog = backlog
      @config = config
    end

    # @return [void]
    def run
      Rhino.logger.log("Rhino")
      Rhino.logger.log("#{@bind}:#{@port}")

      @socket = Socket.new(:INET, :STREAM)
      @socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, @reuseaddr)
      @socket.bind(Addrinfo.tcp(@bind, @port))
      @socket.listen(@backlog)

      Rhino::Server.new(application, [@socket]).run
    ensure
      @socket.close
    end

    # @return [#call] a Rack application
    def application
      @application ||= eval(builder, nil, @config) # rubocop:disable Security/Eval
    end

  private

    # @return [String] Ruby source that builds a Rack application
    def builder
      <<~BUILDER
        Rack::Builder.new do
          #{File.read(@config)}
        end
      BUILDER
    end
  end
end
