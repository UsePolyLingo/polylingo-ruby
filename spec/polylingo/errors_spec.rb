# frozen_string_literal: true

RSpec.describe "PolyLingo errors" do
  let(:base_url) { "http://polylingo.test/v1" }
  let(:client) { PolyLingo::Client.new(api_key: "k", base_url: base_url) }

  it "raises AuthError on 401" do
    stub_request(:get, "#{base_url}/health")
      .to_return(status: 401, body: { "error" => "unauthorized", "message" => "bad key" }.to_json)

    expect { client.health }.to raise_error(PolyLingo::AuthError) do |e|
      expect(e.status).to eq(401)
      expect(e.error).to eq("unauthorized")
      expect(e.message).to eq("bad key")
    end
  end

  it "raises RateLimitError with retry_after from JSON body" do
    stub_request(:get, "#{base_url}/usage")
      .to_return(status: 429, body: { "error" => "rate_limited", "message" => "slow down", "retry_after" => 42 }.to_json)

    expect { client.usage }.to raise_error(PolyLingo::RateLimitError) do |e|
      expect(e.retry_after).to eq(42)
    end
  end

  it "raises RateLimitError with retry_after from Retry-After header" do
    stub_request(:get, "#{base_url}/usage")
      .to_return(
        status: 429,
        headers: { "Retry-After" => "7" },
        body: { "error" => "rate_limited", "message" => "slow" }.to_json
      )

    expect { client.usage }.to raise_error(PolyLingo::RateLimitError) do |e|
      expect(e.retry_after).to eq(7)
    end
  end

  it "wraps non-JSON bodies as unknown_error" do
    stub_request(:get, "#{base_url}/health")
      .to_return(status: 500, body: "upstream exploded", headers: { "Content-Type" => "text/plain" })

    expect { client.health }.to raise_error(PolyLingo::PolyLingoError) do |e|
      expect(e.error).to eq("unknown_error")
      expect(e.message).to eq("upstream exploded")
    end
  end
end
