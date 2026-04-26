# frozen_string_literal: true

require "bundler/setup"
require "webmock/rspec"
require "polylingo"

WebMock.disable_net_connect!(allow_localhost: true)
