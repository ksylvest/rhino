# frozen_string_literal: true

module Rhino
  # A wrapper for command line interaction that encompasses option parsing, version, help, and execution.
  #
  # Usage:
  #
  #   cli = Rhino::CLI.new
  #   cli.parse
  #
  class CLI
    BANNER = "usage: rhino [options] [./config.ru]"

    DEFAULT_BIND = "0.0.0.0"
    DEFAULT_PORT = 5000
    DEFAULT_BACKLOG = 64
    DEFAULT_REUSEADDR = true

    # @param items [Array<String>] the command line arguments
    # @return [void]
    def parse(items = ARGV)
      config = Slop.parse(items) do |options|
        options.banner = BANNER

        options.on("-h", "--help", "help") { return help(options) }
        options.on("-v", "--version", "version") { return version }

        options.string "-b", "--bind", "bind (default: 0.0.0.0)", default: DEFAULT_BIND
        options.integer "-p", "--port", "port (default: 5000)", default: DEFAULT_PORT
        options.integer "--backlog", "backlog (default: 64)", default: DEFAULT_BACKLOG
        options.boolean "--reuseaddr", "reuseaddr (default: true)", default: DEFAULT_REUSEADDR
      end

      run(config)
    end

  private

    # @param options [Slop::Options]
    # @return [void]
    def help(options)
      Rhino.logger.log(String(options))
    end

    # @return [void]
    def version
      Rhino.logger.log(String(VERSION))
    end

    # @param options [Slop::Result]
    # @return [void]
    def run(options)
      config, = options.arguments
      Launcher.new(options[:port], options[:bind], options[:reuseaddr], options[:backlog], config || "./config.ru").run
    end
  end
end
