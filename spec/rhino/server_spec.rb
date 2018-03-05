require 'spec_helper'

describe Rhino::Server do
  let(:server) { Rhino::Server.new(application, sockets) }

  let(:application) { double(:application) }
  let(:socket) { double(:socket) }
  let(:sockets) { [socket] }
  let(:io) { double(:io) }

  describe '#run' do
    it 'handles interrupt' do
      expect(server).to receive(:monitor) { raise Interrupt }
      expect(Rhino.logger).to receive(:log).with('INTERRUPTED')
      server.run
    end
  end

  describe '#monitor' do
    it 'selects then accepts and handles a valid connection' do
      expect(IO).to receive(:select).with(sockets) { io }
      expect(io).to receive(:accept) { socket }
      expect(socket).to receive(:close)

      expect(Rhino::HTTP).to receive(:handle).with(socket, application)

      server.monitor
    end

    it 'handles a "Rhino::ParseError"' do
      expect(IO).to receive(:select).with(sockets) { io }
      expect(io).to receive(:accept) { socket }
      expect(socket).to receive(:close)

      expect(Rhino::HTTP).to receive(:handle).with(socket, application) do
        raise Rhino::ParseError, 'some parse error'
      end

      expect(Rhino.logger).to receive(:log).with('EXCEPTION: some parse error')

      server.monitor
    end
  end

end
