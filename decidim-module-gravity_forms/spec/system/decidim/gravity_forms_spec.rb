# frozen_string_literal: true

require "spec_helper"

describe "Gravity forms", type: :system do
  include_context "with a component"

  before do
    driven_by(:selenium_firefox_headless_billy)
    switch_to_host(organization.host)
  end

  let(:manifest_name) { "gravity_forms" }

  let(:component) do
    create(
      :gravity_forms_component,
      participatory_space: participatory_space,
      settings: { "domain" => "victorious-dog.w6.gravitydemo.com" }
    )
  end

  matcher :render_in_iframe do |content|
    match do |page|
      page.within_frame "js-iframe" do
        expect(page).to have_content(content)
      end
    end
  end

  describe "index page" do
    let(:require_login) { false }

    before do
      create(
        :gravity_form,
        component: component,
        title: "My first form",
        description: "Fill this in to become super cool",
        slug: "cuki-form",
        form_number: 1,
        require_login: require_login
      )
    end

    context "when a single form available" do
      before do
        visit main_component_path(component)
      end

      it "redirects to the only available form" do
        expect(page).to render_in_iframe("Tell us a little about yourself")
      end
    end

    context "when multiple forms available" do
      let(:second_form) do
        create(
          :gravity_form,
          component: component,
          title: "My second form",
          description: "Fill this in to become even cooler",
          slug: "cuki-form-2",
          form_number: 2
        )
      end

      context "and only one visible" do
        before do
          second_form.update!(hidden: true)
          visit main_component_path(component)
        end

        it "redirects to the only visible form" do
          expect(page).to render_in_iframe("Tell us a little about yourself")
        end
      end

      context "and more than one visible" do
        before do
          second_form.update!(hidden: false)
          visit main_component_path(component)
        end

        shared_examples_for "a gravity form list" do
          it "lists all visible forms and titles" do
            expect(page).to have_selector(".card--gravity_form", count: 2)

            expect(page).to have_selector(".card--gravity_form", text: "My first form Fill this in to become super cool")
            expect(page).to have_selector(".card--gravity_form", text: "My second form Fill this in to become even cooler")
          end
        end

        shared_examples_for "a locked form" do
          it "does not grant access" do
            within find(".card--gravity_form", text: "My first form") do
              click_link "Fill in"
            end

            expect(page).to have_content "Please sign in"
            expect(page).not_to have_selector("iframe")
          end
        end

        shared_examples_for "a public form" do
          it "grants access" do
            within find(".card--gravity_form", text: "My first form") do
              click_link "Fill in"
            end

            expect(page).to render_in_iframe("Tell us a little about yourself")
          end
        end

        context "when no hidden forms" do
          it_behaves_like "a gravity form list"
        end

        context "when some hidden forms" do
          before do
            create(
              :gravity_form,
              component: component,
              title: "My third form",
              description: "I'm invisible",
              slug: "cuki-form-3",
              form_number: 3,
              hidden: true
            )

            refresh
          end

          it_behaves_like "a gravity form list"
        end

        context "when user logged in" do
          let(:require_login) { false }

          before do
            login_as user, scope: :user
            refresh
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
    let!(:gravity_form) do
      create(
        :gravity_form,
        component: component,
        title: "My cuki form",
        description: "Fill this in to become super cool",
        slug: "cuki-form",
        form_number: 1
      )
    end

    before do
      visit decidim_participatory_process_gravity_forms.gravity_form_path(
        id: gravity_form.id,
        participatory_process_slug: participatory_space.slug,
        component_id: component.id
      )
    end

    it "shows gravity form title" do
      expect(page).to have_i18n_content(gravity_form.title)
    end

    it "shows grativy form description" do
      expect(page).to have_i18n_content(gravity_form.description)
    end

    it "shows gravity form content" do
      expect(page).to render_in_iframe("Tell us a little about yourself")
    end
  end
end
