# frozen_string_literal: true

# This class performs a request to the census database for personal data handling
class CensusAuthorizationHandler < Decidim::AuthorizationHandler
  include ActionView::Helpers::SanitizeHelper

  attribute :first_name, String
  attribute :last_name1, String
  attribute :last_name2, String

  attribute :document_type, Symbol
  attribute :document_id, String
  attribute :born_at, Date
  attribute :gender, Symbol
  attribute :address, String
  attribute :address_scope_id, Integer
  attribute :postal_code, String
  attribute :scope_id, Integer
  attribute :phone, String

  validates :first_name, :last_name1, :born_at, presence: true, if: :needs_data?
  validates :document_type, inclusion: { in: %w(dni nie passport) }, presence: true, if: :needs_data?
  validates :document_number, format: { with: /\A[A-z0-9]*\z/ }, presence: true, if: :needs_data?
  validates :postal_code, presence: true, format: { with: /\A[0-9]*\z/ }, if: :needs_data?
  validates :scope_id, presence: true, if: :needs_data?

  validate :document_type_valid, if: :needs_data?
  validate :over_14, if: :needs_data?

  def metadata
    {}
  end

  def census_document_types
    %w(dni nie passport).map do |type|
      [I18n.t(type, scope: "decidim.census_authorization_handler.document_types"), type]
    end
  end

  def unique_id
    nil
  end

  def needs_data?
    if @needs_data.nil?
      census_authorizations = CensusAuthorizationHandler.descendants.map(&:to_s)
      @needs_data = !user.authorizations.where(name: census_authorizations).exists?
    end
    @needs_data
  end

  private

  def document_type_valid
    return nil if response.blank?

    errors.add(:document_number, I18n.t("census_authorization_handler.invalid_document")) unless response.xpath("//codiRetorn").text == "01"
  end

  def response
    return nil if document_number.blank? ||
                  document_type.blank? ||
                  postal_code.blank? ||
                  born_at.blank?

    return @response if defined?(@response)

    response ||= Faraday.post "https://#{Rails.application.secrets.census_domain}/api/procedure.json" do |request|
      request.headers["Content-Type"] = "text/json"
      request.body = attributes.to_json
    end

    @response ||= JSON::parse(response.body)
  end

  def over_14
    errors.add(:born_at, I18n.t("census_authorization_handler.age_under_14")) unless age && age >= 14
  end

  def age
    return nil if born_at.blank?

    now = Date.current
    extra_year = (now.month > born_at.month) || (
      now.month == born_at.month && now.day >= born_at.day
    )

    now.year - born_at.year - (extra_year ? 0 : 1)
  end
end
