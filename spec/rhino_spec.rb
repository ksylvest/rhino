require 'spec_helper'

describe Rhino do

  describe '.config' do
    it "is an instance of 'Rhino::Config'" do
      expect(Rhino.config).to be_kind_of(Rhino::Config)
    end
  end

  describe '.logger' do
    it "is an instance of 'Rhino::Logger'" do
      expect(Rhino.logger).to be_kind_of(Rhino::Logger)
    end
  end

end
