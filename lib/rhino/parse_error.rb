# frozen_string_literal: true

module Rhino
  # Raised when an HTTP request line or header line cannot be parsed.
  class ParseError < StandardError
  end
end
