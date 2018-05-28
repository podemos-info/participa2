# frozen_string_literal: true

# Helper methods for stubbing Census API calls
module CensusTestHelpers
  def stub_totals_request(amount)
    stub_request(:get, %r{/api/v1/payments/orders/total})
      .to_return(
        status: 200,
        body: { amount: amount }.to_json,
        headers: {}
      )
  end

  def stub_totals_request_error
    stub_request(:get, %r{/api/v1/payments/orders/total})
      .to_return(
        status: 422,
        body: { error: 422, errorMessage: "Error message" }.to_json,
        headers: {}
      )
  end

  def stub_totals_service_down
    stub_request(:get, %r{/api/v1/payments/orders/total})
      .to_raise(service_unavailable_exception)
  end

  def stub_payment_methods(payment_methods)
    stub_request(:get, %r{/api/v1/payments/payment_methods})
      .to_return(
        status: 200,
        body: payment_methods.to_json,
        headers: {}
      )
  end

  def stub_payment_methods_error
    stub_request(:get, %r{/api/v1/payments/payment_methods})
      .to_return(
        status: 422,
        body: "Error message",
        headers: {}
      )
  end

  def stub_payment_methods_service_down
    allow(::Census::API::PaymentMethod).to receive(:get)
      .with("/api/v1/payments/payment_methods", anything)
      .and_raise(service_unavailable_exception)
  end

  def stub_payment_method_service_down
    allow(::Census::API::PaymentMethod).to receive(:get)
      .with("/api/v1/payments/payment_method", anything)
      .and_raise(service_unavailable_exception)
  end

  def stub_payment_method(payment_method)
    stub_request(:get, %r{/api/v1/payments/payment_method})
      .to_return(
        status: 200,
        body: payment_method.to_json,
        headers: {}
      )
  end

  def stub_orders(http_response_code, json)
    stub_request(:post, %r{/api/v1/payments/orders})
      .to_return(
        status: http_response_code,
        body: json.to_json,
        headers: {}
      )
  end

  def stub_orders_service_down
    allow(::Census::API::Order).to receive(:post)
      .with("/api/v1/payments/orders", anything)
      .and_raise(service_unavailable_exception)
  end

  def service_unavailable_exception
    response = Net::HTTPServiceUnavailable.new("1.1", 503, "Service Unavailable")
    Net::HTTPFatalError.new("503 Service Unavailable", response)
  end
end

RSpec.configure do |config|
  config.include CensusTestHelpers
end
