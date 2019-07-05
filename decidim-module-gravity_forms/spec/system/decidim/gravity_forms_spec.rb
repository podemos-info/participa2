# frozen_string_literal: true

require "spec_helper"

describe "Gravity forms", type: :system, billy: true do
  include_context "with a component"

  before do
    switch_to_host(organization.host)
    gravity_form
  end

  let(:manifest_name) { "gravity_forms" }
  let(:require_login) { false }

  let(:component) do
    create(
      :gravity_forms_component,
      participatory_space: participatory_space,
      settings: { "domain" => "victorious-dog.w6.gravitydemo.com" }
    )
  end
  let(:gravity_form) do
    create(
      :gravity_form,
      component: component,
      form_number: 1,
      require_login: require_login
    )
  end
  let(:second_form) do
    create(
      :gravity_form,
      component: component,
      form_number: 2,
      hidden: second_hidden
    )
  end
  let(:second_hidden) { false }

  matcher :render_in_iframe do |content|
    match do |page|
      page.within_frame "js-iframe" do
        expect(page).to have_content(content)
      end
    end
  end

  describe "index page" do
    context "when a single form available" do
      it "redirects to the only available form" do
        visit_component
        expect(page).to render_in_iframe("Tell us a little about yourself")
      end
    end

    context "when multiple forms available" do
      before { second_form }

      context "and only one visible" do
        let(:second_hidden) { true }

        it "redirects to the only visible form" do
          visit_component
          expect(page).to render_in_iframe("Tell us a little about yourself")
        end
      end

      context "and more than one visible" do
        let(:second_hidden) { false }

        shared_examples_for "a gravity form list" do
          it "lists all visible forms and titles" do
            visit_component

            expect(page).to have_selector(".card--gravity_form", count: 2)

            expect(page).to have_i18n_content(gravity_form.title)
            expect(page).to have_i18n_content(gravity_form.description)
            expect(page).to have_i18n_content(second_form.title)
            expect(page).to have_i18n_content(second_form.description)
          end
        end

        shared_examples_for "a locked form" do
          it "does not grant access" do
            visit_component

            within find(".card--gravity_form", text: translated(gravity_form.title)) do
              click_link "Fill in"
            end

            expect(page).to have_content "Please sign in"
            expect(page).not_to have_selector("iframe")
          end
        end

        shared_examples_for "a public form" do
          it "grants access" do
            visit_component

            within find(".card--gravity_form", text: translated(gravity_form.title)) do
              click_link "Fill in"
            end

            expect(page).to render_in_iframe("Tell us a little about yourself")
          end
        end

        context "when no hidden forms" do
          it_behaves_like "a gravity form list"
        end

        context "when some hidden forms" do
          before { third_form }

          let(:third_form) do
            create(
              :gravity_form,
              component: component,
              form_number: 3,
              hidden: true
            )
          end

          it_behaves_like "a gravity form list"
        end

        context "when user logged in" do
          let(:require_login) { true }

          before do
            login_as user, scope: :user
          end

          it_behaves_like "a public form"
        end

        context "when user not logged in" do
          context "and form unlocked" do
            let(:require_login) { false }

            it_behaves_like "a public form"
          end

          context "and form locked" do
            let(:require_login) { true }

            it_behaves_like "a locked form"
          end
        end
      end
    end
  end

  describe "show page" do
    before { second_form }

    it "shows gravity form title" do
      visit_component
      click_link translated(gravity_form.title)
      expect(page).to have_i18n_content(gravity_form.title)
    end

    it "shows gravity form content" do
      visit_component
      click_link translated(gravity_form.title)
      expect(page).to render_in_iframe("Tell us a little about yourself")
    end
  end
end
