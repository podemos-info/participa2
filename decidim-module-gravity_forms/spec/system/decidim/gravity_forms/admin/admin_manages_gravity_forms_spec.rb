# frozen_string_literal: true

require "spec_helper"

describe "Admin manages gravity forms", type: :system do
  let(:manifest_name) { "gravity_forms" }

  let!(:gravity_form) { create :gravity_form, component: current_component }

  include_context "when managing a component as an admin"

  it_behaves_like "manage gravity forms"
end
