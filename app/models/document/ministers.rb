module Document::Ministers
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_before_save(document)
      document.ministerial_roles = @document.ministerial_roles
    end
  end

  included do
    has_many :document_ministerial_roles, foreign_key: :document_id, dependent: :destroy
    has_many :ministerial_roles, through: :document_ministerial_roles

    add_trait Trait
  end
  
  def can_be_associated_with_ministers?
    true
  end

  module ClassMethods
    def in_ministerial_role(role)
      joins(:ministerial_roles).where('roles.id' => role)
    end
  end
end