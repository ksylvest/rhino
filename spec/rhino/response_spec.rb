# frozen_string_literal: true

require "spec_helper"

describe Rhino::Response do
  let(:socket) { instance_double(Socket) }
  let(:output) { [] }

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

  before { allow(socket).to receive(:write) { |data| output << data } }

  describe ".flush" do
    before do
      described_class.flush(socket, 200, { "Content-Type" => "text/html" }, ["<html></html>"],
        "Thu, 01 Jan 1970 00:00:00 GMT")
    end

    it "flushes a result" do
      expect(output).to eql(response)
    end
  end
end
