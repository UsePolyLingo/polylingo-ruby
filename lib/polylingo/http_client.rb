# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module PolyLingo
  # net/http wrapper: auth, JSON, timeouts (seconds), error mapping.
  class HttpClient
    DEFAULT_BASE_URL = "https://api.usepolylingo.com/v1"

    def initialize(api_key:, base_url:, timeout:)
      @api_key = api_key
      @base_url = base_url.chomp("/")
      @timeout = timeout
    end

    # +expect_status+ may be a single Integer or an Array of acceptable statuses.
    def request(path, method:, body: nil, expect_status: 200)
      path = path.start_with?("/") ? path : "/#{path}"
      uri = URI("#{@base_url}#{path}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      req = build_request(uri, method, body)

      begin
        res = http.request(req)
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ETIMEDOUT
        raise PolyLingoError.new(408, "timeout", "Request timed out after #{@timeout}s")
      end

      text = res.body.to_s
      parsed = parse_body(text)

      expected = Array(expect_status).map(&:to_i)
      unless expected.include?(res.code.to_i)
        raise error_from_response(res.code.to_i, parsed, res)
      end

      parsed
    end

    private

    def build_request(uri, method, body)
      klass = case method.to_s.upcase
              when "GET" then Net::HTTP::Get
              when "POST" then Net::HTTP::Post
              else
                raise ArgumentError, "Unsupported HTTP method: #{method}"
              end

      req = klass.new(uri.request_uri)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Accept"] = "application/json"
      if body
        req["Content-Type"] = "application/json"
        req.body = JSON.generate(body)
      end
      req
    end

    def parse_body(text)
      return {} if text.nil? || text.empty?

      begin
        JSON.parse(text)
      rescue JSON::ParserError
        { "error" => "unknown_error", "message" => text }
      end
    end

    def error_from_response(status, obj, res)
      h = obj.is_a?(Hash) ? obj : {}
      code = h["error"].is_a?(String) ? h["error"] : "unknown_error"
      message = if h["message"].is_a?(String)
                  h["message"]
                else
                  "Request failed with status #{status}"
                end

      if status == 401
        return AuthError.new(status, code, message)
      end

      if status == 429
        retry_after = parse_retry_after(h, res)
        return RateLimitError.new(status, code, message, retry_after)
      end

      PolyLingoError.new(status, code, message)
    end

    def parse_retry_after(h, res)
      raw = h["retry_after"]
      num = parse_retry_after_value(raw)
      return num unless num.nil?

      header = res["retry-after"]
      return nil if header.nil? || header.empty?

      parse_retry_after_value(header)
    end

    def parse_retry_after_value(raw)
      case raw
      when Numeric
        n = raw.to_i
        n >= 0 ? n : nil
      when String
        n = Integer(raw, 10)
        n >= 0 ? n : nil
      else
        nil
      end
    rescue ArgumentError, TypeError
      nil
    end
  end
end
