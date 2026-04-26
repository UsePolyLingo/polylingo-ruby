# frozen_string_literal: true

module PolyLingo
  class Client
    attr_reader :jobs

    # @param api_key [String] API key (required)
    # @param base_url [String, nil] API base URL (default: production)
    # @param timeout [Numeric] request open/read timeout in **seconds** (default: 120)
    def initialize(api_key:, base_url: nil, timeout: 120)
      if api_key.nil? || api_key.to_s.empty?
        raise ArgumentError, "PolyLingo: api_key is required"
      end

      @api_key = api_key
      resolved_base = base_url.nil? || base_url.to_s.empty? ? HttpClient::DEFAULT_BASE_URL : base_url
      @http = HttpClient.new(
        api_key: @api_key,
        base_url: resolved_base.chomp("/"),
        timeout: timeout
      )
      @jobs = Resources::Jobs.new(@http)
    end

    def health
      Resources::Health.call(@http)
    end

    def languages
      Resources::Languages.call(@http)
    end

    def usage
      Resources::Usage.call(@http)
    end

    def translate(content:, targets:, format: nil, source: nil, model: nil)
      Resources::Translate.call(
        @http,
        content: content,
        targets: targets,
        format: format,
        source: source,
        model: model
      )
    end

    def batch(items:, targets:, source: nil, model: nil)
      Resources::Batch.call(
        @http,
        items: items,
        targets: targets,
        source: source,
        model: model
      )
    end
  end
end
