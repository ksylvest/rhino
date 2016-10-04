require "spec_helper"

describe Rhino::Logger do

  let(:stream) { double(:stream) }

  describe "#log" do
    it "proxies to stream" do
      logger = Rhino::Logger.new(stream)
      expect(stream).to receive(:puts).with("Hello!")
      logger.log("Hello!")
    end
  end

end
