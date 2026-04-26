# frozen_string_literal: true

module PolyLingo
  # Base error for all PolyLingo API failures.
  class PolyLingoError < StandardError
    attr_reader :status, :error

    def initialize(status, error, message)
      super(message)
      @status = status
      @error = error
    end
  end

  # Invalid or missing API key (HTTP 401).
  class AuthError < PolyLingoError
  end

  # Rate limited (HTTP 429).
  class RateLimitError < PolyLingoError
    attr_reader :retry_after

    def initialize(status, error, message, retry_after = nil)
      super(status, error, message)
      @retry_after = retry_after
    end
  end

  # Async job finished with status +failed+ or polling timed out.
  class JobFailedError < PolyLingoError
    attr_reader :job_id

    def initialize(job_id, status, error, message)
      super(status, error, message)
      @job_id = job_id
    end
  end
end
