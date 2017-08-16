# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Decidim.mailer_sender
  layout "mailer"
end
