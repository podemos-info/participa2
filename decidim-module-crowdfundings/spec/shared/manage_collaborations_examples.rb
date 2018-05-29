# frozen_string_literal: true

shared_examples "manage collaborations" do
  let(:valid_until) do
    current_component.participatory_space.steps.first.end_date.strftime("%Y-%m-%d")
  end

  describe "creating a new collaboration" do
    before do
      find(".card-title a.button").click
    end

    it "with invalid data" do
      within ".new_collaboration" do
        fill_in :collaboration_minimum_custom_amount, with: 1_000
        select "100", from: :collaboration_default_amount
        fill_in :collaboration_target_amount, with: 1_000_000
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Check the form data and correct the errors.")
      end

      expect(page).to have_content("NEW COLLABORATION CAMPAIGN")
    end

    it "with valid data" do
      fill_in_i18n(
        :collaboration_title,
        "#collaboration-title-tabs",
        en: "My collaboration",
        es: "Mi colaboración",
        ca: "La meua col·laboració"
      )

      fill_in_i18n_editor(
        :collaboration_description,
        "#collaboration-description-tabs",
        en: "My collaboration description",
        es: "La descripción de la colaboración",
        ca: "La descripció de la col·laboració"
      )

      fill_in_i18n_editor(
        :collaboration_terms_and_conditions,
        "#collaboration-terms_and_conditions-tabs",
        en: "My collaboration terms and conditions",
        es: "Los términos y condiciones de mi campaña de colaboración",
        ca: "Els termes i condicions de la meva campanya de col·laboració"
      )

      fill_in :collaboration_minimum_custom_amount, with: 1_000
      fill_in :collaboration_target_amount, with: 100_000
      select "100", from: :collaboration_default_amount

      within ".new_collaboration" do
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My collaboration")
      end
    end
  end

  describe "updating a collaboration" do
    before do
      within find("tr", text: translated(collaboration.title)) do
        page.find("a.action-icon--edit").click
      end
    end

    it "with invalid data" do
      within ".edit_collaboration" do
        fill_in :collaboration_target_amount, with: 0
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Check the form data and correct the errors")
      end

      expect(page).to have_content("EDIT COLLABORATION CAMPAIGN")
    end

    it "with valid data" do
      within ".edit_collaboration" do
        fill_in_i18n(
          :collaboration_title,
          "#collaboration-title-tabs",
          en: "My updated collaboration",
          es: "Mi colaboración actualizada",
          ca: "La meua col·laboració actualitzada"
        )

        fill_in_i18n_editor(
          :collaboration_description,
          "#collaboration-description-tabs",
          en: "My updated collaboration description",
          es: "La descripción de la colaboración actualizada",
          ca: "La descripció de la col·laboració actualitzada"
        )

        fill_in_i18n_editor(
          :collaboration_terms_and_conditions,
          "#collaboration-terms_and_conditions-tabs",
          en: "My updated collaboration terms and conditions",
          es: "Los términos y condiciones de mi campaña de colaboración actualizados",
          ca: "Els termes i condicions de la meva campanya de col·laboració actualitzats"
        )

        fill_in :collaboration_minimum_custom_amount, with: 1_500
        fill_in :collaboration_target_amount, with: 150_000
        select "50", from: :collaboration_default_amount
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My updated collaboration")
      end
    end
  end

  describe "deleting a collaboration" do
    let!(:collaboration2) { create(:collaboration, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a collaboration" do
      within find("tr", text: translated(collaboration2.title)) do
        accept_confirm { page.find("a.action-icon--remove").click }
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(collaboration2.title))
      end
    end
  end

  describe "previewing collaborations" do
    before do
      stub_payment_methods([])
    end

    it "allows the user to preview the collaboration" do
      within find("tr", text: translated(collaboration.title)) do
        new_window = window_opened_by { find("a.action-icon--preview").click }

        within_window new_window do
          expect(page).to have_current_path(resource_locator(collaboration).path)
          expect(page).to have_content(translated(collaboration.title))
        end
      end
    end
  end
end
