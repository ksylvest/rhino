module Rhino

  # A wrapper for command line interaction that encompasses option parsing, version, help, and execution.
  #
  # Usage:
  #
  #   cli = Rhino::CLI.new
  #   cli.parse
  #
  class CLI
    BANNER = 'usage: rhino [options] [./config.ru]'.freeze

    DEFAULT_BIND = '0.0.0.0'.freeze
    DEFAULT_PORT = 5000
    DEFAULT_BACKLOG = 64
    DEFAULT_REUSEADDR = true

    def parse(items = ARGV)
      config = Slop.parse(items) do |options|
        options.banner = BANNER

        options.on('-h', '--help', 'help') { return help(options) }
        options.on('-v', '--version', 'version') { return version }

        options.string '-b', '--bind', 'bind (default: 0.0.0.0)', default: DEFAULT_BIND
        options.integer '-p', '--port', 'port (default: 5000)', default: DEFAULT_PORT
        options.integer '--backlog', 'backlog (default: 64)', default: DEFAULT_BACKLOG
        options.boolean '--reuseaddr', 'reuseaddr (default: true)', default: DEFAULT_REUSEADDR
      end

      run(config)
    end

  private

    def help(options)
      Rhino.logger.log(String(options))
    end

    def version
      Rhino.logger.log(String(VERSION))
    end

    def run(options)
      config, = options.arguments
      Launcher.new(options[:port], options[:bind], options[:reuseaddr], options[:backlog], config || './config.ru').run
    end

  end
end
