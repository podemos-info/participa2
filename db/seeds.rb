# frozen_string_literal: true

def main_organization
  @main_organization ||= Decidim::Organization.first
end

def load_real_scopes
  Decidim::CensusConnector::Seeds::Scopes.seed(main_organization) unless main_organization.top_scopes.any?
end

def localize(text)
  { ca: text, es: text, eu: text, gl: text } # TO-DO: load translations
end

# Faker needs to have the `:en` locale in order to work properly, so we
# must enforce it during the seeds.
original_locales = I18n.available_locales
I18n.available_locales = original_locales + [:en] unless original_locales.include?(:en)

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
  Decidim::Core::Engine.load_seed
end

base_path ||= File.expand_path("seeds/", __dir__)

main_organization.update!(
  name: "Participa Podemos",
  host: ENV["DECIDIM_HOST"] || "localhost",
  twitter_handler: "ahorapodemos",
  facebook_handler: "ahorapodemos",
  instagram_handler: "ahorapodemos",
  youtube_handler: "CirculosPodemos",
  github_handler: "podemos-info",
  welcome_text: localize("Bienvenido/a al Portal de Participación de Podemos."),
  description: localize("<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                      y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                      y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                      debatamos y decidamos entre todos y todas."),
  logo: File.new(File.join(base_path, "assets", "images", "logo.png")),
  homepage_image: File.new(File.join(base_path, "assets", "images", "homepage_image.jpg")),
  official_img_header: File.new(File.join(base_path, "assets", "images", "official-logo-header.png")),
  official_img_footer: File.new(File.join(base_path, "assets", "images", "official-logo-footer.png")),
  favicon: File.new(File.join(base_path, "assets", "images", "icon.svg")),
  official_url: "http://podemos.info",
  default_locale: Decidim.default_locale,
  available_locales: original_locales,
  reference_prefix: "POD",
  available_authorizations: Decidim.authorization_workflows.map(&:name)
)

load_real_scopes

parent = Decidim::Assembly.create!(
  title: localize("Podemos Estatal"),
  slug: "podemos-estatal",
  subtitle: localize("Espacio de participación para todas las personas que forman parte de Podemos"),
  hashtag: "#podemos-participa",
  short_description: localize("<p>Descripción corta</p>"),
  description: localize("<p>Descripción larga</p>"),
  hero_image: File.new(File.join(base_path, "assets", "images", "circle.jpg")),
  banner_image: File.new(File.join(base_path, "assets", "images", "va2.jpg")),
  promoted: true,
  published_at: Time.zone.now,
  organization: main_organization,
  meta_scope: nil,
  developer_group: nil,
  local_area: nil,
  target: nil,
  participatory_scope: nil,
  participatory_structure: nil,
  scope: nil,
  purpose_of_action: nil,
  composition: nil,
  assembly_type: "participatory",
  creation_date: nil,
  created_by: nil,
  duration: nil,
  included_at: nil,
  closing_date: nil,
  closing_date_reason: nil,
  internal_organisation: nil
)

Decidim.component_manifests.each do |manifest|
  manifest.seed!(parent.reload)
end

local_scope = Decidim::Scope.find_by(code: Decidim::CensusConnector.census_local_code)
local_scope.children.each do |scope|
  local_name = scope.name[Decidim.default_locale.to_s]
  child = Decidim::Assembly.create!(
    title: scope.name.map { |locale, name| [locale, "Podemos #{name}"] }.to_h,
    slug: "podemos-#{local_name.parameterize}",
    subtitle: localize("Espacio de participación para todas las personas que forman parte de Podemos"),
    hashtag: "##{local_name.parameterize}-participa",
    short_description: localize("<p>Descripción corta</p>"),
    description: localize("<p>Descripción larga</p>"),
    hero_image: File.new(File.join(base_path, "assets", "images", "circle.jpg")),
    banner_image: File.new(File.join(base_path, "assets", "images", "va2.jpg")),
    promoted: false,
    published_at: Time.zone.now,
    organization: main_organization,
    meta_scope: nil,
    developer_group: nil,
    local_area: nil,
    target: nil,
    participatory_scope: nil,
    participatory_structure: nil,
    scope: scope,
    purpose_of_action: nil,
    composition: nil,
    assembly_type: "participatory",
    creation_date: nil,
    created_by: nil,
    duration: nil,
    included_at: nil,
    closing_date: nil,
    closing_date_reason: nil,
    internal_organisation: nil,
    parent: parent
  )
  Decidim.component_manifests.each do |manifest|
    manifest.seed!(child.reload)
  end
end

I18n.available_locales = original_locales
