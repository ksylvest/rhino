require 'spec_helper'

describe Rhino::CLI do
  let(:cli) { Rhino::CLI.new }

  describe '#parse' do
    %w[-v --version].each do |option|
      it "supports '#{option}' option" do
        expect(Rhino.logger).to receive(:log).with Rhino::VERSION
        cli.parse([option])
      end
    end

    %w[-h --help].each do |option|
      it "supports '#{option}'" do
        expect(Rhino.logger).to receive(:log).with <<~DEBUG
          usage: rhino [options] [./config.ru]
              -h, --help     help
              -v, --version  version
              -b, --bind     bind (default: 0.0.0.0)
              -p, --port     port (default: 5000)
              --backlog      backlog (default: 64)
              --reuseaddr    reuseaddr (default: true)
        DEBUG
        cli.parse([option])
      end
    end

    it 'builds a launcher and executes run' do
      launcher = double(:launcher)
      expect(Rhino::Launcher).to receive(:new).with(4000, 'localhost', true, 16, './config.ru') { launcher }
      expect(launcher).to receive(:run)
      cli.parse(['--port', '4000', '--bind', 'localhost', '--backlog', '16'])
    end
  end

end
