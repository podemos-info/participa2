# frozen_string_literal: true

require "spec_helper"
load "decidim/gravity_forms/version"

describe Decidim::GravityForms do
  describe "#version" do
    subject { described_class.version }

    it { is_expected.to eq(Decidim.version) }
  end
end
