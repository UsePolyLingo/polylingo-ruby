# frozen_string_literal: true

require "erb"

module PolyLingo
  module Resources
    class Jobs
      DEFAULT_POLL_INTERVAL = 5
      DEFAULT_TIMEOUT = 1200

      def initialize(http)
        @http = http
      end

      def create(content:, targets:, format: nil, source: nil, model: nil)
        body = {
          "content" => content,
          "targets" => targets
        }
        body["format"] = format unless format.nil?
        body["source"] = source unless source.nil?
        body["model"] = model unless model.nil?

        @http.request("/jobs", method: :post, body: body, expect_status: 202)
      end

      def get(job_id)
        enc = ERB::Util.url_encode(job_id.to_s)
        @http.request("/jobs/#{enc}", method: :get, expect_status: 200)
      end

      # Submit a translation job and poll until it completes or fails.
      # +poll_interval+ and +timeout+ are in **seconds** (Ruby convention).
      def translate(content:, targets:, format: nil, source: nil, model: nil,
                    poll_interval: DEFAULT_POLL_INTERVAL, timeout: DEFAULT_TIMEOUT,
                    on_progress: nil)
        job = create(
          content: content,
          targets: targets,
          format: format,
          source: source,
          model: model
        )
        job_id = job["job_id"]
        if job_id.nil? || job_id.to_s.empty?
          raise JobFailedError.new("unknown", 500, "invalid_response", "Job create response missing job_id")
        end

        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout.to_f

        loop do
          status = get(job_id)
          st = status["status"]
          if (st == "pending" || st == "processing") && on_progress
            on_progress.call(status["queue_position"])
          end

          case st
          when "completed"
            unless status["translations"] && status["usage"]
              raise JobFailedError.new(
                job_id,
                500,
                "invalid_response",
                "Job completed but translations or usage was missing"
              )
            end
            return {
              "translations" => status["translations"],
              "usage" => status["usage"]
            }
          when "failed"
            err = status["error"].is_a?(String) ? status["error"] : "job_failed"
            msg = if status["message"].is_a?(String)
                    status["message"]
                  elsif status["error"].is_a?(String)
                    status["error"]
                  else
                    "Translation job failed"
                  end
            raise JobFailedError.new(job_id, 200, err, msg)
          end

          if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
            raise JobFailedError.new(
              job_id,
              408,
              "timeout",
              "Job polling exceeded the configured timeout"
            )
          end

          sleep(poll_interval)
        end
      end
    end
  end
end
