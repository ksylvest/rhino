# frozen_string_literal: true

require "spec_helper"

describe Rhino::Request do
  let(:socket) { instance_double(Socket, read: "the quick brown fox") }

  describe ".env" do
    subject(:env) { described_class.env(socket) }

    context "with a valid request line and headers" do
      let(:expected) do
        {
          "HTTP_VERSION" => "HTTP/1.1",
          "REQUEST_URI" => "/search?query=sample",
          "REQUEST_METHOD" => "POST",
          "PATH_INFO" => "/search",
          "QUERY_STRING" => "query=sample",
          "SERVER_PORT" => 80,
          "SERVER_NAME" => "localhost",
          "HTTP_CONTENT_TYPE" => "text/html",
          "HTTP_CONTENT_LENGTH" => "19",
          "HTTP_ACCEPT_ENCODING" => "gzip",
          "HTTP_ACCEPT_LANGUAGE" => "en",
          "HTTP_X_ABC_DEF_GHI" => "ABC DEF GHI",
          "HTTP_X_JKL_MNO_PQR" => "JKL MNO PQR",
        }
      end

      before do
        allow(socket).to receive(:gets).and_return(
          "POST /search?query=sample HTTP/1.1#{Rhino::CRLF}",
          "Accept-Encoding: gzip#{Rhino::CRLF}",
          "Accept-Language: en#{Rhino::CRLF}",
          "Content-Type: text/html#{Rhino::CRLF}",
          "Content-Length: 19#{Rhino::CRLF}",
          "X-ABC-DEF-GHI:ABC #{Rhino::CRLF}",
          "  \tDEF#{Rhino::CRLF}",
          "  \tGHI#{Rhino::CRLF}",
          "X-JKL-MNO-PQR:JKL #{Rhino::CRLF}",
          "  \tMNO#{Rhino::CRLF}",
          "  \tPQR#{Rhino::CRLF}",
          Rhino::CRLF
        )
      end

      it "matches a valid request line and headers" do
        expect(env).to include(expected)
      end
    end

    context "with an invalid request line" do
      let(:line) { Rhino::CRLF }

      before { allow(socket).to receive(:gets).and_return(line) }

      it "raises an exception ('invalid request line')" do
        expect { env }.to raise_error(Rhino::ParseError, "invalid request line: #{line.inspect}")
      end
    end

    context "with an invalid URI in the request line" do
      let(:line) { "GET <> HTTP/1.1#{Rhino::CRLF}" }

      before { allow(socket).to receive(:gets).and_return(line) }

      it "raises an exception ('invalid URI')" do
        expect { env }.to raise_error(Rhino::ParseError, "invalid URI in request line: #{line.inspect}")
      end
    end

    context "with an invalid header line" do
      let(:line) { "Invalid-Request-Line#{Rhino::CRLF}" }

      before do
        allow(socket).to receive(:gets).and_return(
          "GET / HTTP/1.1#{Rhino::CRLF}",
          "Accept-Encoding: gzip#{Rhino::CRLF}",
          "Accept-Language: en#{Rhino::CRLF}",
          line
        )
      end

      it "raises an exception ('invalid header line')" do
        expect { env }.to raise_error(Rhino::ParseError, "invalid header line: #{line.inspect}")
      end
    end
  end
end
