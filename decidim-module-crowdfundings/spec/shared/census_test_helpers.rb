# frozen_string_literal: true

# Helper methods for stubbing Census API calls
module CensusTestHelpers
  def stub_create_order(order_info, http_status: 201)
    stub_request(:post, %r{/api/v1/en/payments/orders})
      .to_return(
        status: http_status,
        body: order_info.to_json,
        headers: {}
      )
  end

  def stub_payment_methods(payment_methods, http_status: 200)
    stub_request(:get, %r{/api/v1/en/payments/payment_methods})
      .to_return(
        status: http_status,
        body: status_response(http_status, payment_methods.map(&:to_h)),
        headers: {}
      )
  end

  def stub_payment_method(payment_method, payment_method_id: payment_method.id, http_status: 200)
    stub_request(:get, %r{/api/v1/en/payments/payment_methods/#{payment_method_id}})
      .to_return(
        status: http_status,
        body: status_response(http_status, payment_method.to_h),
        headers: {}
      )
  end

  def stub_orders_total(amount, http_status: 200)
    stub_request(:get, %r{/api/v1/en/payments/orders/total})
      .to_return(
        status: http_status,
        body: status_response(http_status, amount: amount * 100),
        headers: {}
      )
  end

  def stub_payments_service_down(instance = nil)
    instance = instance.send(:census_payments_api) if instance && !instance.is_a?(Census::API::Payments)
    %w(get patch post).each do |verb|
      if instance
        allow(instance).to receive(verb).and_raise(Faraday::Error::ConnectionFailed.new(Errno::ECONNREFUSED))
      else
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Census::API::Payments).to receive(verb).and_raise(Faraday::Error::ConnectionFailed.new(Errno::ECONNREFUSED))
        # rubocop:enable RSpec/AnyInstance
      end
    end
  end

  private

  def status_response(status, response)
    if status == 204
      ""
    elsif status > 299
      {}
    else
      response
    end.to_json
  end
end

RSpec.configure do |config|
  config.include CensusTestHelpers
end
