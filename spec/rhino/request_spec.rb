require 'spec_helper'

describe Rhino::Request do
  let(:socket) { double(:socket) }
  let(:content) { 'the quick brown fox' }

  describe '.env' do
    subject { Rhino::Request.env(socket) }

    it 'matches a valid request line and headers' do
      expect(socket).to receive(:gets) { "POST /search?query=sample HTTP/1.1#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "X-ABC-DEF-GHI:ABC #{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "  \tDEF#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "  \tGHI#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "X-JKL-MNO-PQR:JKL #{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "  \tMNO#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "  \tPQR#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { Rhino::CRLF }
      expect(socket).to receive(:read) { content }

      expect(subject['HTTP_VERSION']).to eql('HTTP/1.1')
      expect(subject['REQUEST_URI']).to eql('/search?query=sample')
      expect(subject['REQUEST_METHOD']).to eql('POST')
      expect(subject['PATH_INFO']).to eql('/search')
      expect(subject['QUERY_STRING']).to eql('query=sample')
      expect(subject['SERVER_PORT']).to eql(80)
      expect(subject['SERVER_NAME']).to eql('localhost')
      expect(subject['CONTENT_TYPE']).to eql('text/html')
      expect(subject['CONTENT_LENGTH']).to eql(content.length)
      expect(subject['HTTP_ACCEPT_ENCODING']).to eql('gzip')
      expect(subject['HTTP_ACCEPT_LANGUAGE']).to eql('en')
      expect(subject['HTTP_X_ABC_DEF_GHI']).to eql('ABC DEF GHI')
      expect(subject['HTTP_X_JKL_MNO_PQR']).to eql('JKL MNO PQR')
    end

    it "raises an exception ('invalid request line') if the request line is invalid" do
      rl = Rhino::CRLF
      expect(socket).to receive(:gets) { rl }

      expect { subject }.to raise_error(Rhino::ParseError, "invalid request line: #{rl.inspect}")
    end

    it "raises an exception ('invalid URI') if the URI in the request line is invalid" do
      rl = "GET <> HTTP/1.1#{Rhino::CRLF}"
      expect(socket).to receive(:gets) { rl }

      expect { subject }.to raise_error(Rhino::ParseError, "invalid URI in request line: #{rl.inspect}")
    end

    it "raises an exception ('invalid header line') if any header line is invalid" do
      hl = "Invalid-Request-Line#{Rhino::CRLF}"
      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::CRLF}" }
      expect(socket).to receive(:gets) { hl }

      expect { subject }.to raise_error(Rhino::ParseError, "invalid header line: #{hl.inspect}")
    end
  end
end
