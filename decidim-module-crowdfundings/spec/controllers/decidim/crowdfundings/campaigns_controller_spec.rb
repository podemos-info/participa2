# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe CampaignsController, type: :controller do
      routes { Decidim::Crowdfundings::Engine.routes }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      let(:component) { create :crowdfundings_component, :participatory_process }
      let(:params) do
        {
          component_id: component.id
        }
      end

      describe "index" do
        context "with one campaign" do
          let!(:campaign) { create(:campaign, component: component) }
          let(:path) do
            EngineRouter
              .main_proxy(component)
              .campaign_path(campaign)
          end

          it "redirects to the campaign page" do
            get :index, params: params
            expect(response).to redirect_to(path)
          end
        end

        context "with several campaigns" do
          let!(:campaigns) { create_list(:campaign, 2, component: component) }

          it "shows the index page" do
            get :index, params: params
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
