# frozen_string_literal: true

require "spec_helper"

describe Rhino::Logger do
  let(:stream) { instance_double(IO, puts: nil) }

  describe "#log" do
    it "proxies to stream" do
      described_class.new(stream).log("Hello!")
      expect(stream).to have_received(:puts).with("Hello!")
    end
  end
end
