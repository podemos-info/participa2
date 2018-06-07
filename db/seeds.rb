# frozen_string_literal: true

class ParticipaSeeder
  def initialize(base_path)
    @base_path = base_path
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

  TOWNS = %w(ES-PV-VI-001 ES-PV-VI-002 ES-PV-VI-059 ES-CM-AB-003 ES-CM-AB-009 ES-CM-AB-029 ES-CM-AB-069 ES-CM-AB-081 ES-VC-A-009 ES-VC-A-011 ES-VC-A-014 ES-VC-A-018 ES-VC-A-031 ES-VC-A-046 ES-VC-A-047 ES-VC-A-049 ES-VC-A-050 ES-VC-A-053 ES-VC-A-059 ES-VC-A-063 ES-VC-A-065 ES-VC-A-066 ES-VC-A-069 ES-VC-A-071 ES-VC-A-076 ES-VC-A-088 ES-VC-A-090 ES-VC-A-093 ES-VC-A-094 ES-VC-A-096 ES-VC-A-099 ES-VC-A-102 ES-VC-A-104 ES-VC-A-111 ES-VC-A-116 ES-VC-A-118 ES-VC-A-119 ES-VC-A-121 ES-VC-A-122 ES-VC-A-123 ES-VC-A-133 ES-VC-A-137 ES-VC-A-138 ES-VC-A-139 ES-VC-A-140 ES-VC-A-902 ES-VC-A-903 ES-AN-AL-013 ES-AN-AL-032 ES-AN-AL-052 ES-AN-AL-066 ES-AN-AL-079 ES-AN-AL-099 ES-AN-AL-902 ES-CL-AV-014 ES-CL-AV-019 ES-CL-AV-047 ES-CL-AV-168 ES-EX-BA-006 ES-EX-BA-011 ES-EX-BA-015 ES-EX-BA-025 ES-EX-BA-044 ES-EX-BA-060 ES-EX-BA-074 ES-EX-BA-083 ES-EX-BA-088 ES-EX-BA-095 ES-EX-BA-149 ES-EX-BA-153 ES-EX-BA-158 ES-IB-PM-003 ES-IB-PM-010 ES-IB-PM-011 ES-IB-PM-015 ES-IB-PM-026 ES-IB-PM-029 ES-IB-PM-031 ES-IB-PM-032 ES-IB-PM-033 ES-IB-PM-036 ES-IB-PM-040 ES-IB-PM-042 ES-IB-PM-046 ES-IB-PM-048 ES-IB-PM-050 ES-IB-PM-052 ES-IB-PM-054 ES-IB-PM-056 ES-IB-PM-061 ES-IB-PM-062 ES-IB-PM-064 ES-CT-B-001 ES-CT-B-006 ES-CT-B-015 ES-CT-B-019 ES-CT-B-023 ES-CT-B-028 ES-CT-B-035 ES-CT-B-040 ES-CT-B-041 ES-CT-B-051 ES-CT-B-056 ES-CT-B-073 ES-CT-B-074 ES-CT-B-076 ES-CT-B-077 ES-CT-B-086 ES-CT-B-089 ES-CT-B-096 ES-CT-B-101 ES-CT-B-102 ES-CT-B-105 ES-CT-B-107 ES-CT-B-108 ES-CT-B-110 ES-CT-B-114 ES-CT-B-118 ES-CT-B-121 ES-CT-B-123 ES-CT-B-124 ES-CT-B-125 ES-CT-B-136 ES-CT-B-147 ES-CT-B-148 ES-CT-B-155 ES-CT-B-161 ES-CT-B-169 ES-CT-B-172 ES-CT-B-180 ES-CT-B-184 ES-CT-B-187 ES-CT-B-194 ES-CT-B-196 ES-CT-B-200 ES-CT-B-205 ES-CT-B-211 ES-CT-B-217 ES-CT-B-219 ES-CT-B-231 ES-CT-B-234 ES-CT-B-245 ES-CT-B-252 ES-CT-B-260 ES-CT-B-263 ES-CT-B-266 ES-CT-B-279 ES-CT-B-284 ES-CT-B-301 ES-CT-B-302 ES-CT-B-307 ES-CT-B-904 ES-CL-BU-018 ES-CL-BU-059 ES-CL-BU-219 ES-EX-CC-037 ES-EX-CC-116 ES-EX-CC-131 ES-EX-CC-148 ES-EX-CC-175 ES-EX-CC-203 ES-EX-CC-212 ES-AN-CA-004 ES-AN-CA-008 ES-AN-CA-012 ES-AN-CA-015 ES-AN-CA-016 ES-AN-CA-020 ES-AN-CA-022 ES-AN-CA-027 ES-AN-CA-028 ES-AN-CA-030 ES-AN-CA-031 ES-AN-CA-032 ES-AN-CA-033 ES-AN-CA-035 ES-VC-CS-004 ES-VC-CS-005 ES-VC-CS-009 ES-VC-CS-011 ES-VC-CS-027 ES-VC-CS-028 ES-VC-CS-032 ES-VC-CS-040 ES-VC-CS-077 ES-VC-CS-084 ES-VC-CS-085 ES-VC-CS-089 ES-VC-CS-095 ES-VC-CS-104 ES-VC-CS-126 ES-VC-CS-135 ES-VC-CS-138 ES-CM-CR-005 ES-CM-CR-013 ES-CM-CR-034 ES-CM-CR-053 ES-CM-CR-056 ES-CM-CR-071 ES-CM-CR-082 ES-CM-CR-087 ES-CM-CR-096 ES-AN-CO-002 ES-AN-CO-017 ES-AN-CO-021 ES-AN-CO-027 ES-AN-CO-038 ES-AN-CO-049 ES-AN-CO-055 ES-AN-CO-056 ES-AN-CO-058 ES-GA-C-002 ES-GA-C-004 ES-GA-C-005 ES-GA-C-006 ES-GA-C-009 ES-GA-C-017 ES-GA-C-024 ES-GA-C-030 ES-GA-C-031 ES-GA-C-051 ES-GA-C-054 ES-GA-C-055 ES-GA-C-058 ES-GA-C-067 ES-GA-C-073 ES-GA-C-078 ES-GA-C-087 ES-CM-CU-078 ES-CM-CU-203 ES-CT-GI-023 ES-CT-GI-066 ES-CT-GI-079 ES-CT-GI-095 ES-CT-GI-117 ES-CT-GI-118 ES-CT-GI-155 ES-CT-GI-193 ES-AN-GR-003 ES-AN-GR-011 ES-AN-GR-017 ES-AN-GR-021 ES-AN-GR-022 ES-AN-GR-023 ES-AN-GR-047 ES-AN-GR-057 ES-AN-GR-071 ES-AN-GR-079 ES-AN-GR-084 ES-AN-GR-087 ES-AN-GR-101 ES-AN-GR-102 ES-AN-GR-111 ES-AN-GR-122 ES-AN-GR-127 ES-AN-GR-134 ES-AN-GR-135 ES-AN-GR-140 ES-AN-GR-144 ES-AN-GR-145 ES-AN-GR-149 ES-AN-GR-150 ES-AN-GR-158 ES-AN-GR-165 ES-AN-GR-173 ES-AN-GR-175 ES-AN-GR-905 ES-AN-GR-911 ES-AN-GR-914 ES-CM-GU-024 ES-CM-GU-046 ES-CM-GU-058 ES-CM-GU-071 ES-CM-GU-105 ES-CM-GU-130 ES-CM-GU-160 ES-CM-GU-220 ES-CM-GU-225 ES-CM-GU-319 ES-PV-SS-030 ES-PV-SS-040 ES-PV-SS-045 ES-PV-SS-064 ES-PV-SS-067 ES-PV-SS-069 ES-PV-SS-079 ES-PV-SS-902 ES-AN-H-002 ES-AN-H-005 ES-AN-H-007 ES-AN-H-010 ES-AN-H-035 ES-AN-H-041 ES-AN-H-042 ES-AN-H-060 ES-AN-H-078 ES-AR-HU-048 ES-AR-HU-060 ES-AR-HU-061 ES-AR-HU-112 ES-AR-HU-125 ES-AR-HU-130 ES-AR-HU-158 ES-AR-HU-213 ES-AN-J-002 ES-AN-J-003 ES-AN-J-009 ES-AN-J-028 ES-AN-J-044 ES-AN-J-050 ES-AN-J-053 ES-AN-J-055 ES-AN-J-060 ES-AN-J-063 ES-AN-J-073 ES-AN-J-086 ES-AN-J-088 ES-AN-J-092 ES-CL-LE-008 ES-CL-LE-010 ES-CL-LE-030 ES-CL-LE-038 ES-CL-LE-089 ES-CL-LE-115 ES-CL-LE-142 ES-CL-LE-189 ES-CL-LE-222 ES-CT-L-120 ES-RI-LO-005 ES-RI-LO-011 ES-RI-LO-021 ES-RI-LO-036 ES-RI-LO-071 ES-RI-LO-084 ES-RI-LO-089 ES-RI-LO-102 ES-RI-LO-130 ES-GA-LU-016 ES-GA-LU-028 ES-GA-LU-058 ES-GA-LU-066 ES-GA-LU-902 ES-MD-M-005 ES-MD-M-006 ES-MD-M-007 ES-MD-M-009 ES-MD-M-010 ES-MD-M-013 ES-MD-M-014 ES-MD-M-015 ES-MD-M-018 ES-MD-M-022 ES-MD-M-023 ES-MD-M-035 ES-MD-M-040 ES-MD-M-045 ES-MD-M-046 ES-MD-M-047 ES-MD-M-049 ES-MD-M-050 ES-MD-M-051 ES-MD-M-053 ES-MD-M-054 ES-MD-M-058 ES-MD-M-061 ES-MD-M-065 ES-MD-M-068 ES-MD-M-073 ES-MD-M-074 ES-MD-M-079 ES-MD-M-080 ES-MD-M-082 ES-MD-M-083 ES-MD-M-084 ES-MD-M-086 ES-MD-M-087 ES-MD-M-092 ES-MD-M-095 ES-MD-M-096 ES-MD-M-104 ES-MD-M-106 ES-MD-M-108 ES-MD-M-113 ES-MD-M-115 ES-MD-M-123 ES-MD-M-127 ES-MD-M-130 ES-MD-M-131 ES-MD-M-132 ES-MD-M-134 ES-MD-M-135 ES-MD-M-141 ES-MD-M-148 ES-MD-M-150 ES-MD-M-160 ES-MD-M-161 ES-MD-M-164 ES-MD-M-167 ES-MD-M-177 ES-MD-M-178 ES-MD-M-181 ES-MD-M-903 ES-AN-MA-002 ES-AN-MA-005 ES-AN-MA-007 ES-AN-MA-008 ES-AN-MA-015 ES-AN-MA-025 ES-AN-MA-051 ES-AN-MA-054 ES-AN-MA-067 ES-AN-MA-069 ES-AN-MA-070 ES-AN-MA-075 ES-AN-MA-080 ES-AN-MA-082 ES-AN-MA-084 ES-AN-MA-091 ES-AN-MA-094 ES-AN-MA-901 ES-MC-MU-002 ES-MC-MU-003 ES-MC-MU-005 ES-MC-MU-008 ES-MC-MU-009 ES-MC-MU-011 ES-MC-MU-012 ES-MC-MU-013 ES-MC-MU-015 ES-MC-MU-016 ES-MC-MU-017 ES-MC-MU-018 ES-MC-MU-019 ES-MC-MU-022 ES-MC-MU-024 ES-MC-MU-026 ES-MC-MU-027 ES-MC-MU-029 ES-MC-MU-030 ES-MC-MU-033 ES-MC-MU-035 ES-MC-MU-036 ES-MC-MU-038 ES-MC-MU-039 ES-MC-MU-043 ES-MC-MU-902 ES-NC-NA-010 ES-NC-NA-016 ES-NC-NA-057 ES-NC-NA-060 ES-NC-NA-077 ES-NC-NA-086 ES-NC-NA-088 ES-NC-NA-097 ES-NC-NA-122 ES-NC-NA-165 ES-NC-NA-201 ES-NC-NA-232 ES-NC-NA-258 ES-NC-NA-901 ES-NC-NA-907 ES-GA-OR-001 ES-GA-OR-009 ES-GA-OR-019 ES-GA-OR-054 ES-GA-OR-085 ES-AS-O-004 ES-AS-O-006 ES-AS-O-008 ES-AS-O-012 ES-AS-O-014 ES-AS-O-020 ES-AS-O-021 ES-AS-O-024 ES-AS-O-025 ES-AS-O-031 ES-AS-O-032 ES-AS-O-033 ES-AS-O-034 ES-AS-O-035 ES-AS-O-036 ES-AS-O-037 ES-AS-O-038 ES-AS-O-040 ES-AS-O-041 ES-AS-O-044 ES-AS-O-045 ES-AS-O-046 ES-AS-O-049 ES-AS-O-055 ES-AS-O-056 ES-AS-O-057 ES-AS-O-058 ES-AS-O-060 ES-AS-O-066 ES-AS-O-069 ES-AS-O-076 ES-CL-P-023 ES-CL-P-080 ES-CL-P-120 ES-CN-GC-002 ES-CN-GC-003 ES-CN-GC-004 ES-CN-GC-006 ES-CN-GC-011 ES-CN-GC-012 ES-CN-GC-014 ES-CN-GC-015 ES-CN-GC-016 ES-CN-GC-017 ES-CN-GC-018 ES-CN-GC-019 ES-CN-GC-020 ES-CN-GC-021 ES-CN-GC-022 ES-CN-GC-023 ES-CN-GC-024 ES-CN-GC-026 ES-CN-GC-028 ES-CN-GC-030 ES-CN-GC-034 ES-GA-PO-003 ES-GA-PO-006 ES-GA-PO-008 ES-GA-PO-017 ES-GA-PO-021 ES-GA-PO-022 ES-GA-PO-023 ES-GA-PO-024 ES-GA-PO-026 ES-GA-PO-029 ES-GA-PO-035 ES-GA-PO-038 ES-GA-PO-039 ES-GA-PO-042 ES-GA-PO-054 ES-GA-PO-057 ES-GA-PO-060 ES-GA-PO-061 ES-CL-SA-010 ES-CL-SA-046 ES-CL-SA-107 ES-CL-SA-274 ES-CN-TF-001 ES-CN-TF-005 ES-CN-TF-006 ES-CN-TF-011 ES-CN-TF-017 ES-CN-TF-020 ES-CN-TF-022 ES-CN-TF-023 ES-CN-TF-024 ES-CN-TF-026 ES-CN-TF-028 ES-CN-TF-031 ES-CN-TF-032 ES-CN-TF-035 ES-CN-TF-036 ES-CN-TF-038 ES-CN-TF-043 ES-CB-S-008 ES-CB-S-016 ES-CB-S-018 ES-CB-S-020 ES-CB-S-023 ES-CB-S-035 ES-CB-S-040 ES-CB-S-042 ES-CB-S-052 ES-CB-S-059 ES-CB-S-060 ES-CB-S-061 ES-CB-S-068 ES-CB-S-073 ES-CB-S-074 ES-CB-S-075 ES-CB-S-079 ES-CB-S-085 ES-CB-S-087 ES-CL-SG-076 ES-CL-SG-138 ES-CL-SG-170 ES-CL-SG-194 ES-AN-SE-004 ES-AN-SE-005 ES-AN-SE-015 ES-AN-SE-017 ES-AN-SE-021 ES-AN-SE-022 ES-AN-SE-023 ES-AN-SE-024 ES-AN-SE-028 ES-AN-SE-029 ES-AN-SE-034 ES-AN-SE-038 ES-AN-SE-039 ES-AN-SE-040 ES-AN-SE-041 ES-AN-SE-044 ES-AN-SE-045 ES-AN-SE-049 ES-AN-SE-053 ES-AN-SE-055 ES-AN-SE-056 ES-AN-SE-058 ES-AN-SE-059 ES-AN-SE-060 ES-AN-SE-067 ES-AN-SE-068 ES-AN-SE-069 ES-AN-SE-070 ES-AN-SE-071 ES-AN-SE-081 ES-AN-SE-085 ES-AN-SE-086 ES-AN-SE-087 ES-AN-SE-091 ES-AN-SE-093 ES-AN-SE-095 ES-AN-SE-903 ES-CL-SO-173 ES-CT-T-004 ES-CT-T-012 ES-CT-T-014 ES-CT-T-037 ES-CT-T-038 ES-CT-T-051 ES-CT-T-123 ES-CT-T-131 ES-CT-T-136 ES-CT-T-148 ES-CT-T-153 ES-CT-T-155 ES-CT-T-161 ES-CT-T-163 ES-CT-T-171 ES-CT-T-904 ES-CT-T-905 ES-AR-TE-013 ES-AR-TE-216 ES-CM-TO-006 ES-CM-TO-034 ES-CM-TO-052 ES-CM-TO-056 ES-CM-TO-064 ES-CM-TO-081 ES-CM-TO-099 ES-CM-TO-102 ES-CM-TO-106 ES-CM-TO-119 ES-CM-TO-121 ES-CM-TO-123 ES-CM-TO-127 ES-CM-TO-142 ES-CM-TO-161 ES-CM-TO-165 ES-CM-TO-168 ES-CM-TO-176 ES-CM-TO-201 ES-VC-V-005 ES-VC-V-007 ES-VC-V-009 ES-VC-V-011 ES-VC-V-013 ES-VC-V-015 ES-VC-V-017 ES-VC-V-021 ES-VC-V-022 ES-VC-V-029 ES-VC-V-031 ES-VC-V-032 ES-VC-V-035 ES-VC-V-039 ES-VC-V-048 ES-VC-V-054 ES-VC-V-055 ES-VC-V-070 ES-VC-V-074 ES-VC-V-077 ES-VC-V-078 ES-VC-V-081 ES-VC-V-082 ES-VC-V-083 ES-VC-V-094 ES-VC-V-102 ES-VC-V-105 ES-VC-V-109 ES-VC-V-110 ES-VC-V-111 ES-VC-V-116 ES-VC-V-126 ES-VC-V-131 ES-VC-V-135 ES-VC-V-145 ES-VC-V-147 ES-VC-V-155 ES-VC-V-156 ES-VC-V-159 ES-VC-V-164 ES-VC-V-165 ES-VC-V-166 ES-VC-V-169 ES-VC-V-171 ES-VC-V-177 ES-VC-V-179 ES-VC-V-184 ES-VC-V-186 ES-VC-V-190 ES-VC-V-194 ES-VC-V-199 ES-VC-V-202 ES-VC-V-204 ES-VC-V-205 ES-VC-V-207 ES-VC-V-213 ES-VC-V-214 ES-VC-V-215 ES-VC-V-216 ES-VC-V-220 ES-VC-V-223 ES-VC-V-230 ES-VC-V-231 ES-VC-V-233 ES-VC-V-235 ES-VC-V-237 ES-VC-V-238 ES-VC-V-244 ES-VC-V-249 ES-VC-V-250 ES-VC-V-256 ES-VC-V-257 ES-VC-V-258 ES-VC-V-260 ES-CL-VA-007 ES-CL-VA-076 ES-CL-VA-086 ES-CL-VA-186 ES-PV-BI-002 ES-PV-BI-012 ES-PV-BI-013 ES-PV-BI-015 ES-PV-BI-016 ES-PV-BI-020 ES-PV-BI-027 ES-PV-BI-034 ES-PV-BI-043 ES-PV-BI-044 ES-PV-BI-052 ES-PV-BI-054 ES-PV-BI-069 ES-PV-BI-071 ES-PV-BI-077 ES-PV-BI-078 ES-PV-BI-080 ES-PV-BI-082 ES-PV-BI-085 ES-PV-BI-089 ES-PV-BI-090 ES-PV-BI-901 ES-CL-ZA-021 ES-CL-ZA-275 ES-AR-Z-008 ES-AR-Z-066 ES-AR-Z-067 ES-AR-Z-089 ES-AR-Z-095 ES-AR-Z-153 ES-AR-Z-163 ES-AR-Z-182 ES-AR-Z-251 ES-AR-Z-252 ES-AR-Z-297 ES-ML-001).to_set.freeze

  def fix_seed_locales
    # Faker needs to have the `:en` locale in order to work properly, so we must enforce it during the seeds.
    @original_locales = I18n.available_locales
    I18n.available_locales = @original_locales + [:en] unless @original_locales.include?(:en)
    yield
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
      welcome_text: localize("Bienvenido/a al Portal de Participación de Podemos."),
      description: localize("<strong>Podemos</strong> nace con la voluntad de construir una forma nueva de hacer política,
                          y para ello estamos construyendo una estructura transparente, ciudadana, abierta, democrática
                          y eficaz. Una organización que responda al impulso democratizador de Podemos, en la que discutamos,
                          debatamos y decidamos entre todos y todas."),
      logo: File.new(File.join(@base_path, "assets/images/logo.png")),
      homepage_image: File.new(File.join(@base_path, "assets/images/homepage_image.jpg")),
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

    Decidim::Core::Engine.load_seed if !Rails.env.production? || ENV["SEED"]
    Decidim::System::CreateDefaultPages.call(organization) if new_organization?
    Decidim::CensusConnector::Engine.load_seed
  end

  def seed_assemblies
    # create main assembly
    create_assembly(title: "Podemos Estatal", promoted: true)

    local_scope.children.each do |autonomous_community|
      assembly = create_scoped_assembly(scope: autonomous_community)

      # autonomous cities assemblies has no children
      next if autonomous_community.scope_type_id == SCOPE_TYPES[:autonomous_city]

      # create town assemblies, grouped by island, by province or all together
      if autonomous_community.descendants.where(scope_type_id: SCOPE_TYPES[:island]).exists?
        autonomous_community.children.each do |province|
          province.children.each do |island|
            island_assembly = create_scoped_assembly(scope: island, parent_assembly: assembly)
            create_towns_assemblies(scope: island, parent_assembly: island_assembly)
          end
        end
      elsif autonomous_community.children.count > 1
        autonomous_community.children.each do |province|
          province_assembly = create_scoped_assembly(scope: province, parent_assembly: assembly)
          create_towns_assemblies(scope: province, parent_assembly: province_assembly)
        end
      else
        create_towns_assemblies(scope: autonomous_community.children[0], parent_assembly: assembly)
      end
    end

    # create exterior assembly
    create_assembly(title: "Podemos Exterior", where: " en el exterior", scope: non_local_scope, promoted: true)
  end

  def create_towns_assemblies(scope:, parent_assembly:)
    scope.children.each do |town|
      next unless TOWNS.include? town.code
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
    create_collaborations(assembly, title: title)
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

  def create_collaborations(assembly, title:)
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(organization.available_locales, :collaborations).i18n_name,
      manifest_name: :collaborations,
      published_at: Time.current,
      participatory_space: assembly
    )

    component.update!(
      permissions: {
        "support" => {
          "authorization_handler_name" => "census",
          "options" => {
            "minimum_age" => 18,
            "allowed_document_types" => %w(dni nie)
          }
        }
      }
    )

    Decidim::Collaborations::Collaboration.create!(
      component: component,
      title: localize("Colabora con #{title}"),
      description: localize("<p>Colabora con Podemos de la manera más sencilla y personalizada. Elige cantidad, periodicidad y forma de pago.</p>"),
      terms_and_conditions: localize("<p>ToS</p>"),
      minimum_custom_amount: 10,
      default_amount: 100,
      amounts: Decidim::Collaborations.selectable_amounts
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

  def new_organization?
    @new_organization ||= Decidim::Organization.where(twitter_handler: "ahorapodemos").exists?
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
