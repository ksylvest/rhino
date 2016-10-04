require "spec_helper"

describe Rhino::Server do
  let(:server) { Rhino::Server.new(application, sockets) }

  let(:application) { double(:application) }
  let(:socket) { double(:socket) }
  let(:sockets) { [socket] }

  describe "#run" do
    it "handles interrupt" do
      expect(server).to receive(:monitor) { raise Interrupt.new }
      expect(Rhino.logger).to receive(:log).with("INTERRUPTED")
      server.run
    end
  end

  describe "#monitor" do
    it "selects then accepts and handles a valid connection" do
      io = double(:io)
      socket = double(:socket)
      http = double(:http)

      expect(Rhino::HTTP).to receive(:new).with(socket, application) { http }
      expect(http).to receive(:handle)

      expect(IO).to receive(:select).with(sockets) { io }
      expect(io).to receive(:accept) { socket }
      expect(socket).to receive(:close)

      server.monitor
    end

    it "selects then accepts and handles an invalid connection" do
      io = double(:io)
      socket = double(:socket)
      http = double(:http)

      expect(Rhino::HTTP).to receive(:new).with(socket, application) { http }
      expect(http).to receive(:handle) { raise Rhino::HTTP::Exception.new("invalid request line") }

      expect(IO).to receive(:select).with(sockets) { io }
      expect(io).to receive(:accept) { socket }
      expect(socket).to receive(:close)

      expect(Rhino.logger).to receive(:log).with("EXCEPTION: invalid request line")

      server.monitor
    end
  end

end
