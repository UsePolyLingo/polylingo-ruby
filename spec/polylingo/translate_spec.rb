# frozen_string_literal: true

RSpec.describe "PolyLingo translate" do
  let(:base_url) { "http://polylingo.test/v1" }
  let(:client) { PolyLingo::Client.new(api_key: "test-key", base_url: base_url) }

  it "POSTs /translate and returns parsed JSON" do
    stub_request(:post, "#{base_url}/translate")
      .with(
        body: hash_including(
          "content" => "# Hello",
          "targets" => %w[es fr],
          "format" => "markdown"
        ),
        headers: {
          "Authorization" => "Bearer test-key",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      )
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: {
          "translations" => { "es" => "Hola", "fr" => "Bonjour" },
          "usage" => { "total_tokens" => 10 }
        }.to_json
      )

    r = client.translate(content: "# Hello", targets: %w[es fr], format: "markdown")
    expect(r["translations"]["es"]).to eq("Hola")
    expect(r["usage"]["total_tokens"]).to eq(10)
  end
end
