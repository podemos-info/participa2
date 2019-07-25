# frozen_string_literal: true

require "spec_helper"
require "decidim/census_connector/version"

describe Decidim::CensusConnector do
  describe "#version" do
    subject { described_class.version }

    it { is_expected.to eq(Decidim.version) }
  end
end
