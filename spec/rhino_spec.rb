# frozen_string_literal: true

require "spec_helper"

describe Rhino do
  describe ".config" do
    it "is an instance of 'Rhino::Config'" do
      expect(described_class.config).to be_a(Rhino::Config)
    end
  end

  describe ".logger" do
    it "is an instance of 'Rhino::Logger'" do
      expect(described_class.logger).to be_a(Rhino::Logger)
    end
  end
end
