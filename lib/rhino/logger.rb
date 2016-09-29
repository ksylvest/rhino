module Rhino
  class Logger
    attr_accessor :stream

    def initialize(stream = STDOUT)
      self.stream = stream
    end

    def log(message)
      self.stream.puts "#{message}"
    end

  end
end
