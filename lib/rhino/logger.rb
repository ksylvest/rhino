module Rhino

  # A generic logger extracting output for testing. Can be accessed via the global.
  #
  # Usage:
  #
  #   Rhino.logger.log("...")
  #
  class Logger
    attr_accessor :stream

    def initialize(stream = STDOUT)
      self.stream = stream
    end

    def log(message)
      self.stream.puts message
    end

  end

end
