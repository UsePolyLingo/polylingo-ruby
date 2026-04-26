# frozen_string_literal: true

module PolyLingo
  module Resources
    module Usage
      module_function

      def call(http)
        http.request("/usage", method: :get, expect_status: 200)
      end
    end
  end
end
