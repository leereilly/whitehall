class Organisation < ActiveRecord::Base
  include Searchable
  include Rails.application.routes.url_helpers

  belongs_to :organisation_type

  has_many :child_organisational_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationalRelationship"
  has_many :parent_organisational_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationalRelationship"
  has_many :child_organisations, through: :child_organisational_relationships
  has_many :parent_organisations, through: :parent_organisational_relationships

  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document
  has_many :corporate_publications, through: :document_organisations, class_name: "Publication", conditions: {"documents.corporate_publication" => true}, source: :document
  has_many :featured_news_articles, through: :document_organisations, class_name: "NewsArticle", conditions: { "document_organisations.featured" => true, "documents.state" => "published" }, source: :document

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles, class_name: 'MinisterialRole', through: :organisation_roles, source: :role
  has_many :board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role
  has_many :permanent_secretary_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { permanent_secretary: true }
  has_many :other_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { permanent_secretary: false }

  has_many :people, through: :roles

  has_many :organisation_policy_areas
  has_many :policy_areas, through: :organisation_policy_areas

  has_many :contacts
  accepts_nested_attributes_for :contacts, reject_if: :contact_and_contact_numbers_are_blank
  validates :name, presence: true, uniqueness: true
  validates :organisation_type_id, presence: true

  default_scope order(:name)

  searchable title: :name, link: :search_link, content: :description

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.in_listing_order
    joins(:organisation_type).all.sort_by { |o| o.organisation_type.listing_order }
  end

  def name_without_prefix
    name.gsub(/^Ministry of/, "").gsub(/^Department (of|for)/, "").gsub(/^Office of the/, "").strip
  end

  def display_name
    acronym || name
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def search_link
    # This should be organisation_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    organisation_path(slug)
  end

  def top_ministerial_role
    ministerial_roles.order(MinisterialRole.arel_table[:cabinet_member].desc).first
  end

  def top_civil_servant
    board_member_roles.order(Role.arel_table[:permanent_secretary].desc).first
  end

  def published_speeches
    ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  private

  def contact_and_contact_numbers_are_blank(attributes)
    attributes.all? { |key, value|
      key == '_destroy' ||
      value.blank? || (
        (key == "contact_numbers_attributes") &&
        value.all? { |contact_number_attributes|
          contact_number_attributes.all? { |contact_number_key, contact_number_value|
            contact_number_key == '_destroy' ||
            contact_number_value.blank?
          }
        }
      )
    }
  end
end