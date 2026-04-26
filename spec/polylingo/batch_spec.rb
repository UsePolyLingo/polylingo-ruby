# frozen_string_literal: true

RSpec.describe "PolyLingo batch" do
  let(:base_url) { "http://polylingo.test/v1" }
  let(:client) { PolyLingo::Client.new(api_key: "k", base_url: base_url) }

  it "POSTs /translate/batch" do
    items = [{ "id" => "1", "content" => "Hello" }]
    stub_request(:post, "#{base_url}/translate/batch")
      .with(body: hash_including("items" => items, "targets" => ["es"]))
      .to_return(status: 200, body: { "results" => [] }.to_json)

    r = client.batch(items: items, targets: ["es"])
    expect(r["results"]).to eq([])
  end
end
