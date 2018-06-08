# frozen_string_literal: true

require "spec_helper"

describe Decidim::GravityForms::Admin::DestroyGravityForm do
  subject { described_class.new(gravity_form) }

  let(:gravity_form) do
    create(
      :gravity_form,
      title: { en: "old-title" },
      description: { en: "old-description" },
      slug: "old-slug",
      form_number: 42,
      require_login: true,
      component: current_component
    )
  end
  let(:current_component) do
    create(:component, manifest_name: "gravity_forms")
  end

  context "when everything is ok" do
    it "destroys the gravity form" do
      subject.call

      expect { gravity_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
