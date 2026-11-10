# frozen_string_literal: true

require "spec_helper"

describe Rhino::Server do
  let(:server) { described_class.new(application, [io]) }

  let(:application) { instance_double(Rack::Builder) }
  let(:socket) { instance_double(Socket, close: nil) }
  let(:io) { instance_double(Socket, accept: [socket, nil]) }

  before { allow(Rhino.logger).to receive(:log) }

  describe "#run" do
    before do
      allow(server).to receive(:monitor).and_raise(Interrupt)
      server.run
    end

    it "handles interrupt" do
      expect(Rhino.logger).to have_received(:log).with("INTERRUPTED")
    end
  end

  describe "#monitor" do
    before { allow(IO).to receive(:select).with([io]).and_return([[io], [], []]) }

    context "with a valid connection" do
      before do
        allow(Rhino::HTTP).to receive(:handle)
        server.monitor
      end

      it "handles the connection" do
        expect(Rhino::HTTP).to have_received(:handle).with(socket, application)
      end

      it "closes the socket" do
        expect(socket).to have_received(:close)
      end
    end

    context 'with a "Rhino::ParseError"' do
      before do
        allow(Rhino::HTTP).to receive(:handle).and_raise(Rhino::ParseError, "some parse error")
        server.monitor
      end

      it "logs the exception" do
        expect(Rhino.logger).to have_received(:log).with("EXCEPTION: some parse error")
      end

      it "closes the socket" do
        expect(socket).to have_received(:close)
      end
    end
  end
end
