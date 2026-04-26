# frozen_string_literal: true

RSpec.describe "PolyLingo jobs" do
  let(:base_url) { "http://polylingo.test/v1" }
  let(:client) { PolyLingo::Client.new(api_key: "k", base_url: base_url) }

  describe "#create" do
    it "POSTs /jobs and expects 202" do
      stub_request(:post, "#{base_url}/jobs")
        .with(body: hash_including("content" => "Hi", "targets" => ["es"]))
        .to_return(status: 202, body: { "job_id" => "j1", "status" => "pending" }.to_json)

      job = client.jobs.create(content: "Hi", targets: ["es"])
      expect(job["job_id"]).to eq("j1")
    end
  end

  describe "#get" do
    it "GETs /jobs/:id" do
      stub_request(:get, "#{base_url}/jobs/j1")
        .to_return(status: 200, body: { "job_id" => "j1", "status" => "processing" }.to_json)

      job = client.jobs.get("j1")
      expect(job["status"]).to eq("processing")
    end
  end

  describe "#translate" do
    it "polls until completed and returns translations + usage" do
      stub_request(:post, "#{base_url}/jobs")
        .to_return(status: 202, body: { "job_id" => "j1", "status" => "pending" }.to_json)

      stub_request(:get, "#{base_url}/jobs/j1")
        .to_return(
          { status: 200, body: { "job_id" => "j1", "status" => "pending", "queue_position" => 2 }.to_json },
          { status: 200,
            body: {
              "job_id" => "j1",
              "status" => "completed",
              "translations" => { "es" => "Hola" },
              "usage" => { "total_tokens" => 3 }
            }.to_json }
        )

      positions = []
      r = client.jobs.translate(
        content: "Hello",
        targets: ["es"],
        poll_interval: 0,
        timeout: 10,
        on_progress: ->(pos) { positions << pos }
      )

      expect(r["translations"]["es"]).to eq("Hola")
      expect(r["usage"]["total_tokens"]).to eq(3)
      expect(positions).to eq([2])
    end

    it "raises JobFailedError when job status is failed" do
      stub_request(:post, "#{base_url}/jobs")
        .to_return(status: 202, body: { "job_id" => "j1" }.to_json)

      stub_request(:get, "#{base_url}/jobs/j1")
        .to_return(
          status: 200,
          body: { "job_id" => "j1", "status" => "failed", "error" => "boom", "message" => "nope" }.to_json
        )

      expect do
        client.jobs.translate(content: "x", targets: ["es"], poll_interval: 0, timeout: 5)
      end.to raise_error(PolyLingo::JobFailedError) do |e|
        expect(e.job_id).to eq("j1")
        expect(e.error).to eq("boom")
        expect(e.message).to eq("nope")
      end
    end

    it "raises JobFailedError on polling timeout" do
      stub_request(:post, "#{base_url}/jobs")
        .to_return(status: 202, body: { "job_id" => "j1" }.to_json)

      stub_request(:get, "#{base_url}/jobs/j1")
        .to_return(status: 200, body: { "job_id" => "j1", "status" => "processing" }.to_json)

      expect do
        client.jobs.translate(content: "x", targets: ["es"], poll_interval: 0.01, timeout: 0.05)
      end.to raise_error(PolyLingo::JobFailedError) do |e|
        expect(e.job_id).to eq("j1")
        expect(e.status).to eq(408)
        expect(e.error).to eq("timeout")
      end
    end
  end
end
