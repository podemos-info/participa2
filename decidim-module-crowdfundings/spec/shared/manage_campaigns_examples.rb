# frozen_string_literal: true

shared_examples "manage crowdfunding campaigns" do
  let(:valid_until) do
    current_component.participatory_space.steps.first.end_date.strftime("%Y-%m-%d")
  end

  describe "creating a new campaign" do
    before do
      find(".card-title a.button").click
    end

    it "with invalid data" do
      within ".new_campaign" do
        fill_in :campaign_minimum_custom_amount, with: 1_000
        select "100", from: :campaign_default_amount
        fill_in :campaign_target_amount, with: 1_000_000
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Check the form data and correct the errors.")
      end

      expect(page).to have_content("NEW CROWDFUNDING CAMPAIGN")
    end

    it "with valid data" do
      fill_in_i18n(
        :campaign_title,
        "#campaign-title-tabs",
        en: "My crowdfunding campaign",
        es: "Mi campaña",
        ca: "La meua campanya"
      )

      fill_in_i18n_editor(
        :campaign_description,
        "#campaign-description-tabs",
        en: "My campaign description",
        es: "La descripción de la campaña",
        ca: "La descripció de la campanya"
      )

      fill_in_i18n_editor(
        :campaign_terms_and_conditions,
        "#campaign-terms_and_conditions-tabs",
        en: "My campaign terms and conditions",
        es: "Los términos y condiciones de mi campaña de crowdfunding",
        ca: "Els termes i condicions de la meva campanya de crowdfunding"
      )

      fill_in :campaign_minimum_custom_amount, with: 1_000
      fill_in :campaign_target_amount, with: 100_000
      select "100", from: :campaign_default_amount

      within ".new_campaign" do
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My crowdfunding campaign")
      end
    end
  end

  describe "updating a campaign" do
    before do
      within find("tr", text: translated(campaign.title)) do
        page.find("a.action-icon--edit").click
      end
    end

    it "with invalid data" do
      within ".edit_campaign" do
        fill_in :campaign_target_amount, with: 0
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Check the form data and correct the errors")
      end

      expect(page).to have_content("EDIT CROWDFUNDING CAMPAIGN")
    end

    it "with valid data" do
      within ".edit_campaign" do
        fill_in_i18n(
          :campaign_title,
          "#campaign-title-tabs",
          en: "My updated crowdfunding campaign",
          es: "Mi campaña actualizada",
          ca: "La meua campanya actualitzada"
        )

        fill_in_i18n_editor(
          :campaign_description,
          "#campaign-description-tabs",
          en: "My updated crowdfunding campaign description",
          es: "La descripción de la campaña actualizada",
          ca: "La descripció de la campanya actualitzada"
        )

        fill_in_i18n_editor(
          :campaign_terms_and_conditions,
          "#campaign-terms_and_conditions-tabs",
          en: "My updated crowdfunding campaign terms and conditions",
          es: "Los términos y condiciones de mi campaña de crowdfunding actualizados",
          ca: "Els termes i condicions de la meva campanya de crowdfunding actualitzats"
        )

        fill_in :campaign_minimum_custom_amount, with: 1_500
        fill_in :campaign_target_amount, with: 150_000
        select "50", from: :campaign_default_amount
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My updated crowdfunding campaign")
      end
    end
  end

  describe "deleting a campaign" do
    let!(:campaign2) { create(:campaign, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a campaign" do
      within find("tr", text: translated(campaign2.title)) do
        accept_confirm { page.find("a.action-icon--remove").click }
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(campaign2.title))
      end
    end
  end

  describe "previewing campaigns" do
    before do
      stub_payment_methods([])
    end

    it "allows the user to preview the campaign" do
      within find("tr", text: translated(campaign.title)) do
        new_window = window_opened_by { find("a.action-icon--preview").click }

        within_window new_window do
          expect(page).to have_current_path(resource_locator(campaign).path)
          expect(page).to have_content(translated(campaign.title))
        end
      end
    end
  end
end
