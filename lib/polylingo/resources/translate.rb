# frozen_string_literal: true

module PolyLingo
  module Resources
    module Translate
      module_function

      def call(http, content:, targets:, format: nil, source: nil, model: nil)
        body = {
          "content" => content,
          "targets" => targets
        }
        body["format"] = format unless format.nil?
        body["source"] = source unless source.nil?
        body["model"] = model unless model.nil?

        http.request("/translate", method: :post, body: body, expect_status: 200)
      end
    end
  end
end
