# frozen_string_literal: true

module PolyLingo
  module Resources
    module Health
      module_function

      def call(http)
        http.request("/health", method: :get, expect_status: 200)
      end
    end
  end
end
