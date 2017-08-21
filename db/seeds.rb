# frozen_string_literal: true

require "participa2/seeds/scopes"

base_path = File.expand_path("./seeds/", __dir__)

organization = Decidim::Organization.first || Decidim::Organization.create!(
  name: "Participa Podemos",
  twitter_handler: "ahorapodemos",
  facebook_handler: "ahorapodemos",
  instagram_handler: "ahorapodemos",
  youtube_handler: "CirculosPodemos",
  github_handler: "podemos-info",
  host: ENV["DECIDIM_HOST"] || "localhost",
  welcome_text: { ca: "Bienvenido/a al Portal de Participación de Podemos.",
                  es: "Bienvenido/a al Portal de Participación de Podemos.",
                  eu: "Bienvenido/a al Portal de Participación de Podemos.",
                  gl: "Bienvenido/a al Portal de Participación de Podemos." },
  description:  { ca: "<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                      y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                      y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                      debatamos y decidamos entre todos y todas.",
                  es: "<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                      y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                      y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                      debatamos y decidamos entre todos y todas.",
                  eu: "<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                      y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                      y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                      debatamos y decidamos entre todos y todas.",
                  gl: "<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                      y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                      y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                      debatamos y decidamos entre todos y todas." },
  logo: File.new(File.join(base_path, "assets", "images", "logo.png")),
  homepage_image: File.new(File.join(base_path, "assets", "images", "homepage_image.jpg")),
  official_img_header: File.new(File.join(base_path, "assets", "images", "official-logo-header.png")),
  official_img_footer: File.new(File.join(base_path, "assets", "images", "official-logo-footer.png")),
  favicon: File.new(File.join(base_path, "assets", "images", "icon.svg")),
  official_url: "http://podemos.info",
  default_locale: Decidim.default_locale,
  available_locales: Decidim.available_locales,
  reference_prefix: "POD"
)

Decidim::System::CreateDefaultPages.call(organization)

Participa2::Seeds::Scopes.seed organization, base_path: base_path