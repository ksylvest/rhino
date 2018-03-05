require 'spec_helper'

describe Rhino::Response do
  let(:socket) { double(:socket) }
  let(:status) { 200 }
  let(:headers) { { 'Content-Type' => 'text/html' } }
  let(:body) { ['<html></html>'] }
  let(:time) { 'Thu, 01 Jan 1970 00:00:00 GMT' }

  describe '.flush' do
    subject(:flush) { Rhino::Response.flush(socket, status, headers, body, time) }

    it 'flushes a result' do
      expect(socket).to receive(:write).with("HTTP/1.1 200 OK#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Connection: close#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Content-Type: text/html#{Rhino::CRLF}")
      expect(socket).to receive(:write).with(Rhino::CRLF)
      expect(socket).to receive(:write).with('<html></html>')

      flush
    end
  end
end
