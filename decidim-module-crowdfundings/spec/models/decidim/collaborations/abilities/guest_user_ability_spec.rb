# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Collaborations::Abilities::GuestUserAbility do
  subject { described_class.new(nil, current_settings: current_settings) }

  let(:current_settings) { {} }
  let(:collaborations_allowed) { true }
  let(:collaboration) { create(:collaboration) }

  before do
    expect(current_settings).to receive(:collaborations_allowed?)
      .at_most(:once)
      .and_return(collaborations_allowed)
  end

  describe "support collaboration" do
    context "when collaboration allowed" do
      let(:collaborations_allowed) { true }

      it "when collaboration accepts supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(true)
        expect(subject).to be_able_to(:support, collaboration)
      end

      it "when collaboration does not accept supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(false)
        expect(subject).not_to be_able_to(:support, collaboration)
      end
    end

    context "when collaboration not allowed" do
      let(:collaborations_allowed) { false }

      it "when collaboration accepts supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(true)
        expect(subject).not_to be_able_to(:support, collaboration)
      end

      it "when collaboration does not accept supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(false)
        expect(subject).not_to be_able_to(:support, collaboration)
      end
    end
  end
end
