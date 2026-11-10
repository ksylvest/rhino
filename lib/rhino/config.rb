# frozen_string_literal: true

module Rhino
  # Configuration options used internally such as multithread and multiprocess. Can be accessed via the global.
  #
  # Usage:
  #
  #   Rhino.config
  #
  # @!attribute [rw] multithread
  #   @return [Boolean, nil]
  # @!attribute [rw] multiprocess
  #   @return [Boolean, nil]
  # @!attribute [rw] run_once
  #   @return [Boolean, nil]
  class Config
    attr_accessor :multithread, :multiprocess, :run_once
  end
end
