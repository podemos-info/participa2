# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "decidim/census_connector/seeds/scopes"

describe Decidim::CensusConnector::Seeds::Scopes do
  describe "#seed" do
    before do
      FileUtils.rm_rf(described_class::CACHE_PATH)
      ENV["SCOPES_CACHE_PATH"] = nil
    end

    let(:organization) { create(:organization) }
    let(:base_path) { File.expand_path("../../../../fixtures/seeds/scopes", __dir__) }
    let(:instance) { described_class.new(organization) }

    it "loads scopes data" do
      expect { instance.seed(base_path: base_path) } .to change { Decidim::Scope.count } .from(0).to(20)
    end

    it "loads scope types data" do
      expect { instance.seed(base_path: base_path) } .to change { Decidim::ScopeType.count } .from(0).to(7)
    end

    it "loads scope data from files" do
      expect(instance).to receive(:save_scope).at_least(1)

      instance.seed(base_path: base_path)
    end

    it "caches scopes after loading originals" do
      expect { instance.seed(base_path: base_path) } .to change { File.exist?(described_class::CACHE_PATH) } .from(false).to(true)
    end

    context "when data is cached" do
      before do
        instance.seed(base_path: base_path)

        Decidim::Scope.delete_all
      end

      it "load cached scopes data" do
        expect { instance.seed(base_path: base_path) } .to change { Decidim::Scope.count } .from(0).to(20)
      end

      it "doesn't load scope data from files" do
        expect(instance).not_to receive(:save_scope)

        instance.seed(base_path: base_path)
      end
    end
  end
end
