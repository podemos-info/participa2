# frozen_string_literal: true

Decidim::GravityForms.configure do |config|
  shared_secret = Digest::SHA512.hexdigest("GF-#{Rails.application.secrets.secret_key_base}")

  config.customize_embed_url = lambda do |user, url|
    return url unless user

    timestamp = Time.zone.now.to_i
    url += "&timestamp=#{timestamp}&decidim_id=#{user.id}%40#{Rails.application.engine_name}-#{user.decidim_organization_id}"
    url + "&signature=#{Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", shared_secret, "#{timestamp}::#{url}")[0..20])}"
  end
end
