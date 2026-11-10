# frozen_string_literal: true

require "spec_helper"

describe Rhino::Launcher do
  let(:launcher) { described_class.new(80, "0.0.0.0", true, 64, "./spec/support/config.ru") }

  describe "#application" do
    it "parses config into rack builder" do
      expect(launcher.application).to be_a(Rack::Builder)
    end
  end

  describe "#run" do
    let(:socket) { instance_double(Socket, setsockopt: nil, bind: nil, listen: nil, close: nil) }
    let(:server) { instance_double(Rhino::Server, run: nil) }

    before do
      allow(Rhino.logger).to receive(:log)
      allow(Socket).to receive(:new).with(:INET, :STREAM).and_return(socket)
      allow(Rhino::Server).to receive(:new).and_return(server)
      launcher.run
    end

    it "logs the name and address", :aggregate_failures do
      expect(Rhino.logger).to have_received(:log).with("Rhino")
      expect(Rhino.logger).to have_received(:log).with("0.0.0.0:80")
    end

    it "configures the socket", :aggregate_failures do
      expect(socket).to have_received(:setsockopt).with(:SOL_SOCKET, :SO_REUSEADDR, true)
      expect(socket).to have_received(:bind)
      expect(socket).to have_received(:listen).with(64)
    end

    it "proxies to server" do
      expect(server).to have_received(:run)
    end

    it "closes the socket" do
      expect(socket).to have_received(:close)
    end
  end
end
