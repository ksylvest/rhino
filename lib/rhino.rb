# frozen_string_literal: true

require "rack"
require "slop"
require "socket"
require "time"
require "uri"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("cli" => "CLI")
loader.inflector.inflect("crlf" => "CRLF")
loader.inflector.inflect("http" => "HTTP")
loader.setup

# A simple Rack compatible HTTP server.
#
# Usage:
#
#   Rhino.config
#   Rhino.logger
#
module Rhino
  # @return [Rhino::Config]
  def self.config
    @config ||= Rhino::Config.new
  end

  # @return [Rhino::Logger]
  def self.logger
    @logger ||= Rhino::Logger.new
  end
end
