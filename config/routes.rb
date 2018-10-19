# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" unless Rails.env.production? || Rails.env.test?

  get "/authorizations" => redirect("/census_account")

  mount Decidim::Core::Engine => "/"
end
