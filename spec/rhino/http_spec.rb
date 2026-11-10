# frozen_string_literal: true

require "spec_helper"

describe Rhino::HTTP do
  let(:socket) { instance_double(Socket, read: "the quick brown fox") }
  let(:output) { [] }

  before do
    allow(Time).to receive(:now).and_return(instance_double(Time, httpdate: "Thu, 01 Jan 1970 00:00:00 GMT"))
    allow(Rhino.logger).to receive(:log)
    allow(socket).to receive(:gets).and_return(
      "GET / HTTP/1.1#{Rhino::CRLF}",
      "Accept-Encoding: gzip#{Rhino::CRLF}",
      "Accept-Language: en#{Rhino::CRLF}",
      "Content-Type: text/html#{Rhino::CRLF}",
      "Content-Length: 19#{Rhino::CRLF}",
      Rhino::CRLF
    )
    allow(socket).to receive(:write) { |data| output << data }
  end

  describe ".handle" do
    context "when the application succeeds" do
      let(:application) do
        instance_double(Rack::Builder, call: [200, { "Content-Type" => "text/html" }, ["<html></html>"]])
      end

      let(:response) do
        [
          "HTTP/1.1 200 OK#{Rhino::CRLF}",
          "Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::CRLF}",
          "Connection: close#{Rhino::CRLF}",
          "Content-Type: text/html#{Rhino::CRLF}",
          Rhino::CRLF,
          "<html></html>",
        ]
      end

      before { described_class.handle(socket, application) }

      it "writes the response" do
        expect(output).to eql(response)
      end

      it "logs the request" do
        expect(Rhino.logger).to have_received(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 200")
      end
    end

    context "when the application raises an exception" do
      let(:application) { instance_double(Rack::Builder) }

      let(:response) do
        [
          "HTTP/1.1 500 Internal Server Error#{Rhino::CRLF}",
          "Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::CRLF}",
          "Connection: close#{Rhino::CRLF}",
          Rhino::CRLF,
        ]
      end

      before do
        allow(application).to receive(:call).and_raise(StandardError, "an unknown error occurred")
        described_class.handle(socket, application)
      end

      it "writes the response" do
        expect(output).to eql(response)
      end

      it "logs the exception" do
        expect(Rhino.logger).to have_received(:log).with("#<StandardError: an unknown error occurred>")
      end

      it "logs the request" do
        expect(Rhino.logger).to have_received(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 500")
      end
    end
  end
end
