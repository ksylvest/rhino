require 'spec_helper'

describe Rhino::HTTP do
  let(:content) { 'the quick brown fox' }
  let(:socket) { double(:socket) }
  let(:application) { double(:application) }

  describe '.handle' do
    it 'handles the request with the application' do
      expect(Time).to receive(:now) { double(:time, httpdate: 'Thu, 01 Jan 1970 00:00:00 GMT') }
      expect(application).to receive(:call) { [200, { 'Content-Type' => 'text/html' }, ['<html></html>']] }

      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { Rhino::CRLF }
      expect(socket).to receive(:read) { content }

      expect(socket).to receive(:write).with("HTTP/1.1 200 OK#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Connection: close#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Content-Type: text/html#{Rhino::CRLF}")
      expect(socket).to receive(:write).with(Rhino::CRLF)
      expect(socket).to receive(:write).with('<html></html>')

      expect(Rhino.logger).to receive(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 200")

      Rhino::HTTP.handle(socket, application)
    end

    it 'handles an exception with the application' do
      expect(Time).to receive(:now) { double(:time, httpdate: 'Thu, 01 Jan 1970 00:00:00 GMT') }

      expect(application).to receive(:call) { raise Exception, 'an unknown error occurred' }

      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { Rhino::CRLF }
      expect(socket).to receive(:read) { content }

      expect(socket).to receive(:write).with("HTTP/1.1 500 Internal Server Error#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::CRLF}")
      expect(socket).to receive(:write).with("Connection: close#{Rhino::CRLF}")
      expect(socket).to receive(:write).with(Rhino::CRLF)

      expect(Rhino.logger).to receive(:log).with('#<Exception: an unknown error occurred>')
      expect(Rhino.logger).to receive(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 500")

      Rhino::HTTP.handle(socket, application)
    end
  end

end
