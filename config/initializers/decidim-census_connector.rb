# frozen_string_literal: true

Decidim::CensusConnector.configure do |config|
  config.census_api_debug = Rails.application.secrets.census[:api_debug]
  config.census_api_base_uri = Rails.application.secrets.census[:api_base_uri]
end

Decidim::CensusConnector.register_activism_type(:volunteers, order: 100) do |person|
  active = person.additional_information["volunteer"].present?

  {
    active: active,
    title: t("volunteers.title"),
    status_icon_params: active ? ["check", class: "success"] : ["x", class: "muted"],
    status_text: active ? t("volunteers.active") : t("volunteers.inactive"),
    edit_link: "https://equipos.podemos.info",
    edit_text: t("decidim.census_connector.account.account.participation.action.modify")
  }
end
