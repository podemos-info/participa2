# frozen_string_literal: true

shared_context "with assembly component" do
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }

  let(:user) { create :user, :confirmed, organization: organization }
  let!(:organization) { create(:organization) }

  let(:assembly) do
    create(:assembly, organization: organization)
  end

  let(:participatory_space) { assembly }

  let!(:component) do
    create(:component,
           manifest: manifest,
           participatory_space: assembly)
  end

  before do
    switch_to_host(organization.host)
  end

  def visit_component
    page.visit main_component_path(component)
  end
end
