# frozen_string_literal: true

shared_examples "manage gravity forms" do
  describe "creating a gravity form" do
    before do
      visit_component_admin

      within ".card-title" do
        click_link "New"
      end
    end

    it "shows all fields" do
      expect(page).to have_field("gravity_form_title_en")
      expect(page).to have_field("gravity_form_description_en")
      expect(page).to have_field("gravity_form_form_number")
      expect(page).to have_field("gravity_form_slug")
      expect(page).to have_field("gravity_form_require_login")
      expect(page).to have_field("gravity_form_hidden")
    end

    it "shows a success message and displays the new form on the index page" do
      within ".new_gravity_form" do
        fill_in_i18n(
          :gravity_form_title,
          "#gravity_form-title-tabs",
          en: "My gravity form",
          es: "Mi gravity form",
          ca: "Meu gravity form"
        )

        fill_in "Form number", with: "1"
        fill_in "Slug", with: "waka-waka"

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My gravity form")
      end
    end
  end

  describe "updating a gravity form" do
    let!(:gravity_form) do
      create(:gravity_form, component: current_component)
    end

    before do
      visit_component_admin

      within find("tr", text: translated(gravity_form.title)) do
        page.find(".action-icon--edit").click
      end
    end

    it "shows a success message and shows the new info back in the index page" do
      within ".edit_gravity_form" do
        fill_in_i18n(
          :gravity_form_title,
          "#gravity_form-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new title")
      end
    end
  end

  describe "previewing gravity forms" do
    shared_examples_for "a gravity form preview" do
      it "allows the user to preview the gravity form" do
        within find("tr", text: translated(gravity_form.title)) do
          klass = "action-icon--preview"
          href = resource_locator(gravity_form).path
          target = "blank"

          expect(page).to have_selector(
            :xpath,
            "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
          )
        end
      end
    end

    context "when visible" do
      before do
        gravity_form.update!(hidden: false)
      end

      it_behaves_like "a gravity form preview"
    end

    context "when hidden" do
      before do
        gravity_form.update!(hidden: true)
      end

      it_behaves_like "a gravity form preview"
    end
  end
end
