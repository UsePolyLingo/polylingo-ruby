# frozen_string_literal: true

module PolyLingo
  module Resources
    module Batch
      module_function

      def call(http, items:, targets:, source: nil, model: nil)
        body = {
          "items" => items,
          "targets" => targets
        }
        body["source"] = source unless source.nil?
        body["model"] = model unless model.nil?

        http.request("/translate/batch", method: :post, body: body, expect_status: 200)
      end
    end
  end
end
