# frozen_string_literal: true

require_relative "polylingo/version"
require_relative "polylingo/errors"
require_relative "polylingo/http_client"
require_relative "polylingo/resources/health"
require_relative "polylingo/resources/languages"
require_relative "polylingo/resources/usage"
require_relative "polylingo/resources/translate"
require_relative "polylingo/resources/batch"
require_relative "polylingo/resources/jobs"
require_relative "polylingo/client"

module PolyLingo
  # @param api_key [String]
  # @param base_url [String, nil]
  # @param timeout [Numeric] seconds (default 120)
  # @return [PolyLingo::Client]
  def self.new(api_key:, base_url: nil, timeout: 120)
    Client.new(api_key: api_key, base_url: base_url, timeout: timeout)
  end
end
