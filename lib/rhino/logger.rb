module Rhino

  # A generic logger extracting output for testing. Can be accessed via the global.
  #
  # Usage:
  #
  #   Rhino.logger.log("...")
  #
  class Logger

    def initialize(stream = $stdout)
      @stream = stream
    end

    def log(message)
      @stream.puts(message)
    end

  end

end
