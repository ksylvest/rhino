# frozen_string_literal: true

module Rhino
  # A generic logger extracting output for testing. Can be accessed via the global.
  #
  # Usage:
  #
  #   Rhino.logger.log("...")
  #
  class Logger
    # @param stream [IO]
    def initialize(stream = $stdout)
      @stream = stream
    end

    # @param message [String]
    # @return [void]
    def log(message)
      @stream.puts(message)
    end
  end
end
