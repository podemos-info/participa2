# frozen_string_literal: true

class ParticipaSeeder
  def initialize(base_path)
    @base_path = base_path
    @towns = File.readlines(File.join(@base_path, "towns.csv")).map(&:strip).to_set.freeze
  end

  def seed
    fix_seed_locales do
      seed_organization
      seed_assemblies
    end
  end

  private

  SCOPE_TYPES = {
    autonomous_city: 8,
    island: 51
  }.freeze

  def fix_seed_locales
    # Faker needs to have the `:en` locale in order to work properly, so we must enforce it during the seeds.
    @original_locales = I18n.available_locales
    I18n.available_locales = @original_locales + [:en] unless @original_locales.include?(:en)
    yield
  ensure
    I18n.available_locales = @original_locales
  end

  def seed_organization
    organization.update!(
      name: "Participa Podemos",
      host: ENV["DECIDIM_HOST"] || "localhost",
      facebook_handler: "ahorapodemos",
      instagram_handler: "ahorapodemos",
      youtube_handler: "CirculosPodemos",
      github_handler: "podemos-info",
      description: localize("<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                          y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                          y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                          debatamos y decidamos entre todos y todas."),
      logo: File.new(File.join(@base_path, "assets/images/logo.png")),
      official_img_header: File.new(File.join(@base_path, "assets/images/official-logo-header.png")),
      official_img_footer: File.new(File.join(@base_path, "assets/images/official-logo-footer.png")),
      favicon: File.new(File.join(@base_path, "assets/images/icon.svg")),
      official_url: "http://podemos.info",
      default_locale: Decidim.default_locale,
      available_locales: @original_locales,
      reference_prefix: "POD",
      available_authorizations: ["census"]
    )

    Decidim::Scope.delete_all
    Decidim::ScopeType.delete_all
    Decidim::Assembly.delete_all
    Decidim::Crowdfundings::Contribution.delete_all
    Decidim::Crowdfundings::Campaign.delete_all
    Decidim::Votings::Voting.delete_all

    if new_organization?
      create_homepage_hero_block
      Decidim::System::CreateDefaultPages.call(organization)
    end

    Decidim::CensusConnector::Engine.load_seed
  end

  def seed_assemblies
    # create main assembly
    create_assembly(title: "Podemos Estatal", promoted: true)

    local_scope.children.each do |autonomous_community|
      print "\r" + " " * 80
      print "\rLoading assemblies... #{local_name(autonomous_community)}"

      assembly = create_scoped_assembly(scope: autonomous_community)

      # autonomous cities assemblies has no children
      next if autonomous_community.scope_type_id == SCOPE_TYPES[:autonomous_city]

      # create town assemblies, grouped by island, by province or all together
      if autonomous_community.descendants.where(scope_type_id: SCOPE_TYPES[:island]).exists?
        autonomous_community.children.each do |province|
          province.children.each do |island|
            island_assembly = create_scoped_assembly(scope: island, parent_assembly: assembly)
            create_towns_assemblies(scope: island, parent_assembly: island_assembly)
            print "."
          end
        end
      elsif autonomous_community.children.count > 1
        autonomous_community.children.each do |province|
          province_assembly = create_scoped_assembly(scope: province, parent_assembly: assembly)
          create_towns_assemblies(scope: province, parent_assembly: province_assembly)
          print "."
        end
      else
        create_towns_assemblies(scope: autonomous_community.children[0], parent_assembly: assembly)
        print "."
      end
    end

    puts "\rLoading assemblies..."

    # create exterior assembly
    create_assembly(title: "Podemos Exterior", where: " en el exterior", scope: non_local_scope)
  end

  def create_towns_assemblies(scope:, parent_assembly:)
    scope.children.each do |town|
      next unless @towns.include? town.code

      create_scoped_assembly(scope: town, parent_assembly: parent_assembly)
    end
  end

  def create_scoped_assembly(scope:, parent_assembly: nil)
    parent_scope_name = local_name(scope.parent) if scope.parent
    scope_name = local_name(scope)
    extra = " (ciudad)" if scope_name == parent_scope_name
    create_assembly(title: "Podemos #{scope_name}#{extra}", where: " en #{scope_name}", scope: scope, parent_assembly: parent_assembly)
  end

  def create_assembly(title:, where: "", scope: nil, parent_assembly: nil, promoted: false)
    assembly = Decidim::Assembly.create!(
      title: localize(title),
      slug: title.parameterize,
      subtitle: localize("Espacio de participación para todas las personas que forman parte de Podemos#{where}"),
      hashtag: "##{title.parameterize}",
      short_description: localize("<p>Descripción corta</p>"),
      description: localize("<p>Descripción larga</p>"),
      hero_image: File.new(File.join(@base_path, "assets/images/circle.jpg")),
      banner_image: File.new(File.join(@base_path, "assets/images/va2.jpg")),
      promoted: promoted,
      published_at: Time.zone.now,
      organization: organization,
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
      parent: parent_assembly
    )
    create_votings(assembly)
    create_gravity_forms(assembly)
    create_crowdfundings(assembly, title: title)
    assembly
  end

  def create_votings(assembly)
    Decidim::Component.create!(
      name: Decidim::Components::Namer.new(organization.available_locales, :votings).i18n_name,
      manifest_name: :votings,
      published_at: Time.current,
      participatory_space: assembly
    )
  end

  def create_gravity_forms(assembly)
    Decidim::Component.create!(
      name: Decidim::Components::Namer.new(organization.available_locales, :gravity_forms).i18n_name,
      manifest_name: :gravity_forms,
      published_at: Time.current,
      participatory_space: assembly,
      settings: {
        domain: "forms.podemos.info"
      }
    )
  end

  def create_crowdfundings(assembly, title:)
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(organization.available_locales, :crowdfundings).i18n_name,
      manifest_name: :crowdfundings,
      published_at: Time.current,
      participatory_space: assembly
    )

    component.update!(
      permissions: {
        "support" => {
          "authorization_handler_name" => "census",
          "options" => {
            "minimum_age" => 18,
            "allowed_document_types" => "dni,nie"
          }
        }
      }
    )

    Decidim::Crowdfundings::Campaign.create!(
      component: component,
      title: localize("Colabora con #{title}"),
      description: localize("<p>Colabora con Podemos de la manera más sencilla y personalizada. Elige cantidad, periodicidad y forma de pago.</p>"),
      terms_and_conditions: localize("<p>ToS</p>"),
      minimum_custom_amount: 10,
      default_amount: 100,
      amounts: Decidim::Crowdfundings.selectable_amounts
    )
  end

  def organization
    @organization ||= begin
      @new_organization = false
      Decidim::Organization.find_or_initialize_by(twitter_handler: "ahorapodemos") do
        @new_organization = true
      end
    end
  end

  def create_homepage_hero_block
    hero_content_block = Decidim::ContentBlock.find_or_initialize_by(
      organization: organization,
      scope: :homepage,
      manifest_name: :hero
    )

    homepage_image = File.new(File.join(@base_path, "assets/images/homepage_image.jpg"))
    hero_content_block.images_container.background_image = homepage_image

    welcome_text = localize("Bienvenido/a al Portal de Participación de Podemos.")

    settings = {}
    settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }

    hero_content_block.settings = settings
    hero_content_block.save!
  end

  def new_organization?
    @new_organization ||= !Decidim::Organization.where(twitter_handler: "ahorapodemos").exists?
  end

  def local_scope
    @local_scope ||= Decidim::Scope.find_by(code: Decidim::CensusConnector.census_local_code)
  end

  def non_local_scope
    @non_local_scope ||= Decidim::Scope.find_by(code: Decidim::CensusConnector.census_non_local_code)
  end

  def local_name(scope)
    scope.name[Decidim.default_locale.to_s]
  end

  def localize(text)
    { ca: text, es: text, eu: text, gl: text } # TO-DO: load translations
  end
end

ParticipaSeeder.new(File.expand_path("seeds/", __dir__)).seed
