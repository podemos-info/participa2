# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe ContributionsHelper do
      let(:form) { {} }

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
