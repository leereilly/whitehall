class DocumentIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  has_many :documents
  has_many :document_relations
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }
  has_one :unpublished_document, class_name: 'Document', conditions: { state: ['draft', 'submitted', 'rejected'] }

  has_one :published_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: { state: 'published' }
  has_one :latest_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: 'NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id)'

  has_one :latest_edition, class_name: 'Document', conditions: 'NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id)'

  attr_accessor :sluggable_string

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def unpublished_edition
    documents.where("state IN (:draft_states)", draft_states: [:draft, :submitted, :rejected]).first
  end

  def update_slug_if_possible(new_title)
    unless published_document.present?
      self.sluggable_string = new_title
      save
    end
  end

  def set_document_type(document_type)
    self.document_type = document_type
  end

  class << self
    def published
      joins(:published_document)
    end
  end
end