require 'spec_helper'

describe Rhino::Launcher do
  let(:port) { 80 }
  let(:bind) { '0.0.0.0' }
  let(:backlog) { 64 }
  let(:reuseaddr) { true }
  let(:config) { './spec/support/config.ru' }
  let(:socket) { double(:socket) }
  let(:server) { double(:server) }

  describe '#application' do
    it 'parses config into rack builder' do
      launcher = Rhino::Launcher.new(port, bind, reuseaddr, backlog, config)
      expect(launcher.application).to be_kind_of(Rack::Builder)
    end
  end

  describe '#run' do
    it 'configures a socket and proxies to server' do
      launcher = Rhino::Launcher.new(port, bind, reuseaddr, backlog, config)

      expect(Rhino.logger).to receive(:log).with('Rhino')
      expect(Rhino.logger).to receive(:log).with('0.0.0.0:80')
      expect(Socket).to receive(:new).with(:INET, :STREAM) { socket }
      expect(socket).to receive(:bind)
      expect(socket).to receive(:setsockopt).with(:SOL_SOCKET, :SO_REUSEADDR, reuseaddr)
      expect(socket).to receive(:listen).with(backlog)
      expect(socket).to receive(:close)

      expect(Rhino::Server).to receive(:new) { server }
      expect(server).to receive(:run)

      launcher.run
    end
  end

end
