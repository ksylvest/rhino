require 'rack'

run proc { [200, { 'Content-Type' => 'text/html' }, ['<html><body>Hello!</body></html>']] }
