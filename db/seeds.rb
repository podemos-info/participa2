# frozen_string_literal: true

def main_organization
  @main_organization ||= Decidim::Organization.find_or_initialize_by(host: ENV["DECIDIM_HOST"] || "localhost")
end

def load_real_scopes
  Decidim::CensusConnector::Seeds::Scopes.seed(main_organization) unless main_organization.top_scopes.any?
end

if !Rails.env.production? || ENV["SEED"]
  class TempClass
    def self.create!(*_args)
      OpenStruct.new(code: "fake")
    end
  end

  class Decidim::Core::Engine
    def load_seed
      truncate_tables
      disable_scopes
      super
      enable_scopes
      load_real_scopes
    end

    private

    def truncate_tables
      tables = ActiveRecord::Base.connection.tables - %w(schema_migrations ar_internal_metadata)

      # Delete fake data
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        conn.execute("TRUNCATE #{tables.join(", ")} RESTART IDENTITY")
      end
    end

    def disable_scopes
      @old_scope_type = Decidim::ScopeType
      @old_scope = Decidim::Scope
      Decidim.const_set("ScopeType", TempClass)
      Decidim.const_set("Scope", TempClass)
    end

    def enable_scopes
      Decidim.const_set("ScopeType", @old_scope_type)
      Decidim.const_set("Scope", @old_scope)
    end
  end

  Decidim.seed!
end

base_path ||= File.expand_path("seeds/", __dir__)
main_organization.update!(
  name: "Participa Podemos",
  twitter_handler: "ahorapodemos",
  facebook_handler: "ahorapodemos",
  instagram_handler: "ahorapodemos",
  youtube_handler: "CirculosPodemos",
  github_handler: "podemos-info",
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
  reference_prefix: "POD",
  available_authorizations: Decidim.authorization_workflows.map(&:name)
)

load_real_scopes
