# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe TotalsHelper do
      describe "percentage_class" do
        it "percentage between 0 and 20: level1" do
          expect(helper.percentage_class(10)).to eq("percentage--level1")
        end

        it "percentage between 20 and 50: level2" do
          expect(helper.percentage_class(40)).to eq("percentage--level2")
        end

        it "percentage between 50 and 80: level3" do
          expect(helper.percentage_class(75)).to eq("percentage--level3")
        end

        it "percentage between 80 and 100: level4" do
          expect(helper.percentage_class(90)).to eq("percentage--level4")
        end

        it "percentage is 100%: level5" do
          expect(helper.percentage_class(100)).to eq("percentage--level5")
        end

        it "blanck in case of invalid percentage" do
          expect(helper.percentage_class(-1)).to be_blank
          expect(helper.percentage_class(nil)).to be_blank
        end
      end

      describe "total_collected_to_currency" do
        let(:subject) { helper.total_collected_to_currency(amount) }

        context "with nil value" do
          let(:amount) { nil }

          it "returns not available" do
            expect(subject).to eq("n/a")
          end
        end
      end
    end
  end
end
