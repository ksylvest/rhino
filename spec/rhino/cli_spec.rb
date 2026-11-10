# frozen_string_literal: true

require "spec_helper"

describe Rhino::CLI do
  let(:cli) { described_class.new }

  before { allow(Rhino.logger).to receive(:log) }

  describe "#parse" do
    let(:usage) do
      <<~USAGE
        usage: rhino [options] [./config.ru]
            -h, --help     help
            -v, --version  version
            -b, --bind     bind (default: 0.0.0.0)
            -p, --port     port (default: 5000)
            --backlog      backlog (default: 64)
            --reuseaddr    reuseaddr (default: true)
      USAGE
    end

    %w[-v --version].each do |option|
      it "supports '#{option}' option" do
        cli.parse([option])
        expect(Rhino.logger).to have_received(:log).with(Rhino::VERSION)
      end
    end

    %w[-h --help].each do |option|
      it "supports '#{option}'" do
        cli.parse([option])
        expect(Rhino.logger).to have_received(:log).with(usage)
      end
    end

    context "with options" do
      let(:launcher) { instance_double(Rhino::Launcher, run: nil) }

      before do
        allow(Rhino::Launcher).to receive(:new).and_return(launcher)
        cli.parse(["--port", "4000", "--bind", "localhost", "--backlog", "16"])
      end

      it "builds a launcher" do
        expect(Rhino::Launcher).to have_received(:new).with(4000, "localhost", true, 16, "./config.ru")
      end

      it "executes run" do
        expect(launcher).to have_received(:run)
      end
    end
  end
end
