require 'spec_helper'

describe Rhino::HTTP do

  let (:content) { SecureRandom.hex }
  let (:socket) { double(:socket) }
  let (:application) { double(:application) }

  describe "#parse" do
    it "matches a valid request line and headers" do
      expect(socket).to receive(:gets) { "POST /search?query=sample HTTP/1.1#{Rhino::HTTP::CRLF}"  }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "X-ABC-DEF-GHI:ABC #{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { "  \tDEF#{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { "  \tGHI#{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { "X-JKL-MNO-PQR:JKL #{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { "  \tMNO#{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { "  \tPQR#{Rhino::HTTP::CRLF}"}
      expect(socket).to receive(:gets) { Rhino::HTTP::CRLF }
      expect(socket).to receive(:read) { content }

      http = Rhino::HTTP.new(socket)
      env = http.parse
      expect(env["HTTP_VERSION"]).to eql("HTTP/1.1")
      expect(env["REQUEST_URI"]).to eql("/search?query=sample")
      expect(env["REQUEST_METHOD"]).to eql("POST")
      expect(env["PATH_INFO"]).to eql("/search")
      expect(env["QUERY_STRING"]).to eql("query=sample")
      expect(env["SERVER_PORT"]).to eql(80)
      expect(env["SERVER_NAME"]).to eql("localhost")
      expect(env["CONTENT_TYPE"]).to eql("text/html")
      expect(env["CONTENT_LENGTH"]).to eql(content.length)
      expect(env["HTTP_ACCEPT_ENCODING"]).to eql("gzip")
      expect(env["HTTP_ACCEPT_LANGUAGE"]).to eql("en")
      expect(env["HTTP_X_ABC_DEF_GHI"]).to eql("ABC DEF GHI")
      expect(env["HTTP_X_JKL_MNO_PQR"]).to eql("JKL MNO PQR")
    end

    it "raises an exception ('invalid request line') if the request line is invalid" do
      rl = Rhino::HTTP::CRLF
      expect(socket).to receive(:gets) { rl }

      expect {
        http = Rhino::HTTP.new(socket)
        env = http.parse
      }.to raise_error(Rhino::HTTP::Exception, "invalid request line: #{rl.inspect}")
    end

    it "raises an exception ('invalid URI') if the URI in the request line is invalid" do
      rl = "GET <> HTTP/1.1#{Rhino::HTTP::CRLF}"
      expect(socket).to receive(:gets) { rl }

      expect {
        http = Rhino::HTTP.new(socket)
        env = http.parse
      }.to raise_error(Rhino::HTTP::Exception, "invalid URI in request line: #{rl.inspect}")
    end

    it "raises an exception ('invalid header line') if any header line is invalid" do
      hl = "Invalid-Request-Line#{Rhino::HTTP::CRLF}"
      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { hl }

      expect {
        http = Rhino::HTTP.new(socket)
        env = http.parse
      }.to raise_error(Rhino::HTTP::Exception, "invalid header line: #{hl.inspect}")
    end
  end

  describe "#handle" do
    it "handles the request with the application" do
      expect(Time).to receive(:now) { double(:time, httpdate: "Thu, 01 Jan 1970 00:00:00 GMT") }
      expect(application).to receive(:call) { [200, { 'Content-Type' => 'text/html' }, ['<html></html>']] }

      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::HTTP::CRLF}"  }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:read) { content }

      expect(socket).to receive(:write).with("HTTP/1.1 200 OK#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with("Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with("Connection: close#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with("Content-Type: text/html#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with(Rhino::HTTP::CRLF)
      expect(socket).to receive(:write).with("<html></html>")

      expect(Rhino.logger).to receive(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 200")

      http = Rhino::HTTP.new(socket)
      http.handle(application)
    end

    it "handles an exception with the application" do
      expect(Time).to receive(:now) { double(:time, httpdate: "Thu, 01 Jan 1970 00:00:00 GMT") }

      expect(application).to receive(:call) { raise ::Exception.new("an unknown error occurred") }

      expect(socket).to receive(:gets) { "GET / HTTP/1.1#{Rhino::HTTP::CRLF}"  }
      expect(socket).to receive(:gets) { "Accept-Encoding: gzip#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Accept-Language: en#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Type: text/html#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "Content-Length: #{content.length}#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:gets) { "#{Rhino::HTTP::CRLF}" }
      expect(socket).to receive(:read) { content }

      expect(socket).to receive(:write).with("HTTP/1.1 500 Internal Server Error#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with("Date: Thu, 01 Jan 1970 00:00:00 GMT#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with("Connection: close#{Rhino::HTTP::CRLF}")
      expect(socket).to receive(:write).with(Rhino::HTTP::CRLF)

      expect(Rhino.logger).to receive(:log).with("#<Exception: an unknown error occurred>")
      expect(Rhino.logger).to receive(:log).with("[Thu, 01 Jan 1970 00:00:00 GMT] 'GET / HTTP/1.1' 500")

      http = Rhino::HTTP.new(socket)
      http.handle(application)
    end
  end

end
