# frozen_string_literal: true

require "csv"

module Decidim
  module CensusConnector
    module Seeds
      class Scopes
        EXTERIOR_SCOPE = "XX"
        CACHE_PATH = Rails.root.join("tmp", "cache", "#{Rails.env}_scopes.csv").freeze

        def initialize(organization)
          @organization = organization
        end

        def seed(options = {})
          base_path = options[:base_path] || File.expand_path("../../../../db/seeds/scopes", __dir__)
          cache_path = ENV["SCOPES_CACHE_PATH"].presence || CACHE_PATH

          puts "Loading scope types..."
          save_scope_types("#{base_path}/scope_types.tsv")

          puts "Loading scopes..."
          if File.exist?(cache_path)
            load_cached_scopes(cache_path)
          else
            load_original_scopes("#{base_path}/scopes.tsv", "#{base_path}/scopes.translations.tsv")
            cache_scopes(cache_path)
          end
        end

        private

        def save_scope_types(source)
          @scope_types = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = {} } }
          CSV.foreach(source, col_sep: "\t", headers: true) do |row|
            @scope_types[row["Code"]][:id] = row["UID"]
            @scope_types[row["Code"]][:organization] = @organization
            @scope_types[row["Code"]][:name][row["Locale"]] = row["Singular"]
            @scope_types[row["Code"]][:plural][row["Locale"]] = row["Plural"]
          end

          Decidim::ScopeType.transaction do
            @scope_types.values.each do |info|
              Decidim::ScopeType.find_or_initialize_by(id: info[:id]).update!(info)
            end
            max_id = Decidim::ScopeType.maximum(:id)
            Decidim::ScopeType.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["ALTER SEQUENCE decidim_scope_types_id_seq RESTART WITH ?", max_id + 1]))
          end
        end

        def load_original_scopes(main_source, translations_source)
          @translations = Hash.new { |h, k| h[k] = {} }
          CSV.foreach(translations_source, col_sep: "\t", headers: true) do |row|
            @translations[row["UID"]][row["Locale"]] = row["Translation"]
          end

          @scope_ids = {}
          CSV.foreach(main_source, col_sep: "\t", headers: true) do |row|
            save_scope row
          end
        end

        def load_cached_scopes(source)
          conn = ActiveRecord::Base.connection.raw_connection
          File.open(source, "r:ASCII-8BIT") do |file|
            conn.copy_data "COPY decidim_scopes FROM STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
              conn.put_copy_data(file.readline) until file.eof?
            end
          end
        end

        def cache_scopes(target)
          conn = ActiveRecord::Base.connection.raw_connection
          File.open(target, "w:ASCII-8BIT") do |file|
            conn.copy_data "COPY (SELECT * FROM decidim_scopes) To STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
              while (row = conn.get_copy_data) do file.puts row end
            end
          end
        end

        def root_code(code)
          code.split(/\W/i).first
        end

        def parent_code(code)
          return nil if code == Decidim::CensusConnector.census_local_code
          parent_code = code.rindex(/\W/i)
          parent_code ? code[0..parent_code - 1] : EXTERIOR_SCOPE
        end

        def save_scope(row)
          print "\r#{row["UID"].ljust(30)}"
          code = row["UID"]

          scope = Decidim::Scope.create!(
            code: code,
            organization: @organization,
            scope_type_id: @scope_types[row["Type"]][:id],
            name: @translations[code],
            parent_id: @scope_ids[parent_code(code)]
          )
          @scope_ids[code] = scope.id
        end
      end
    end
  end
end
