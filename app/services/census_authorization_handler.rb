# frozen_string_literal: true

# This class performs a request to the census database for personal data handling
class CensusAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :first_name, String
  attribute :last_name1, String
  attribute :last_name2, String

  attribute :document_type, Symbol
  attribute :document_id, String
  attribute :born_at, Date
  attribute :gender, Symbol
  attribute :address, String
  attribute :address_scope_id, Integer
  attribute :scope_id, Integer
  attribute :postal_code, String
  attribute :phone, String

  attribute :document_file1
  attribute :document_file2

  attribute :address_scope_code, Integer
  attribute :scope_code, Integer

  validates :first_name, :last_name1, :born_at, presence: true, if: :needs_data?
  validates :document_type, inclusion: { in: %i(dni nie passport) }, presence: true, if: :needs_data?
  validates :gender, inclusion: { in: %i(female male other undisclosed) }, presence: true, if: :needs_data?
  validates :document_id, format: { with: /\A[A-z0-9]*\z/ }, presence: true, if: :needs_data?
  validates :postal_code, presence: true, format: { with: /\A[0-9]*\z/ }, if: :needs_data?
  validates :scope_id, :address_scope_id, presence: true, if: :needs_data?

  validate :over_14, if: :needs_data?

  def level
    raise NotImplementedError, "Subclasses must define `level`."
  end

  def metadata
    {}
  end

  def census_document_types
    %w(dni nie passport).map do |type|
      [I18n.t(type, scope: "decidim.census_authorization_handler.document_types"), type]
    end
  end

  def genders
    %w(female male other undisclosed).map do |type|
      [I18n.t(type, scope: "decidim.census_authorization_handler.genders"), type]
    end
  end

  def unique_id
    nil
  end

  def needs_data?
    if @needs_data.nil?
      census_authorizations = CensusAuthorizationHandler.descendants.map(&:to_s).map(&:underscore)
      @needs_data = !user.authorizations.where(name: census_authorizations).exists?
    end
    @needs_data
  end

  def valid?
    super && response
  end

  def address_scope
    Decidim::Scope.find_by_id(address_scope_id)
  end

  def scope
    Decidim::Scope.find_by_id(scope_id)
  end

  def scope_root
    Decidim::Scope.find_by_code("ES")
  end

  def create_lower_handlers
    CensusAuthorizationHandler.descendants.sort_by(&:order).each do |handler|
      break if handler.class == self.class

      authorization = Decidim::Authorization.find_or_initialize_by(
        user: user,
        name: handler.handler_name
      )

      authorization.save! if authorization.handler.class==handler && !authorization.persisted?
    end
  end

  private

  def prepare_data
    data = { level: level }
    return data if !needs_data?

    data[:person] = attributes.except(:user, :handler_name, :scope_id, :address_scope_id)
    data[:person][:extra] = { participa_id: user.id }
    data[:person][:email] = user.email
    data[:person][:scope_code] = scope&.code
    data[:person][:address_scope_code] = address_scope&.code
    data
  end

  def response
    return @response if defined?(@response)

    if needs_data?
      method = :post
      action = "people"
    else
      method = :patch
      action = "people/#{user.id}/change_membership_level"
    end

    response ||= Faraday.run_request method,
                                     "#{Rails.application.secrets.census_url}/api/v1/#{action}.json",
                                     prepare_data.to_json,
                                     { "Content-Type" => "application/json" }

    response.success? && create_lower_handlers
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

class ActionDispatch::Http::UploadedFile
  def as_json(options={})
    {
      filename: original_filename,
      content_type: content_type,
      base64_content: Base64.encode64(tempfile.read)
    }
  end
end