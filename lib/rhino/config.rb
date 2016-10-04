module Rhino

  # Configuration options used internally such as multithread and multiprocess. Can be accessed via the global.
  #
  # Usage:
  #
  #   Rhino.config
  #
  class Config
    attr_accessor :multithread
    attr_accessor :multiprocess
    attr_accessor :run_once
  end

end
