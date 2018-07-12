# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe ContributionsHelper do
      let(:form) { {} }

      describe "iban_field?" do
        it "existing_payment_method returns false" do
          expect(form).to receive(:payment_method_type).and_return("existing_payment_method")
          expect(helper).not_to be_iban_field(form)
        end

        it "direct_debit returns true" do
          expect(form).to receive(:payment_method_type).and_return("direct_debit")
          expect(helper).to be_iban_field(form)
        end

        it "credit_card_external returns false" do
          expect(form).to receive(:payment_method_type).and_return("credit_card_external")
          expect(helper).not_to be_iban_field(form)
        end
      end

      describe "state_label" do
        it "returns the translated value for each state" do
          Contribution.states.each do |state|
            expect(helper.state_label(state[0])).to eq(I18n.t(state[0].to_sym,
                                                              scope: "decidim.crowdfundings.labels.contribution.states"))
          end
        end
      end
    end
  end
end
