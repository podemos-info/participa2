# frozen_string_literal: true

require "spec_helper"
load "decidim/votings/version"

describe Decidim::Votings do
  describe "#version" do
    subject { described_class.version }

    it { is_expected.to eq(Decidim.version) }
  end
end
