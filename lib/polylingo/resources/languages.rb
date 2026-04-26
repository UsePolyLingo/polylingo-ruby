# frozen_string_literal: true

module PolyLingo
  module Resources
    module Languages
      module_function

      def call(http)
        http.request("/languages", method: :get, expect_status: 200)
      end
    end
  end
end
