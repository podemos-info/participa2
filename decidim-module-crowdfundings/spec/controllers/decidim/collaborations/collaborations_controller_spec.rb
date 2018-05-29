# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe CollaborationsController, type: :controller do
      routes { Decidim::Collaborations::Engine.routes }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      let(:component) { create :collaboration_component, :participatory_process }
      let(:params) do
        {
          component_id: component.id
        }
      end

      describe "index" do
        context "with one collaboration" do
          let!(:collaboration) { create(:collaboration, component: component) }
          let(:path) do
            EngineRouter
              .main_proxy(component)
              .collaboration_path(collaboration)
          end

          it "redirects to the collaboration page" do
            get :index, params: params
            expect(response).to redirect_to(path)
          end
        end

        context "with several collaborations" do
          let!(:collaborations) { create_list(:collaboration, 2, component: component) }

          it "shows the index page" do
            get :index, params: params
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
