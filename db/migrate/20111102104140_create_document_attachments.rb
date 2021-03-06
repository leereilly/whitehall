class CreateDocumentAttachments < ActiveRecord::Migration
  def up
    create_table :document_attachments do |t|
      t.integer :document_id
      t.integer :attachment_id

      t.timestamps
    end
    Document.where("attachment_id IS NOT NULL").each do |document|
      DocumentAttachment.create!(document_id: document.id, attachment_id: document.attachment_id)
    end
    remove_column :documents, :attachment_id
  end

  def down
    add_column :documents, :attachment_id, :integer
    DocumentAttachment.each do |document_attachment|
      document = Document.find(document_attachment.document_id)
      document.update_attribute(:attachment_id, document_attachment.attachment_id)
    end
    drop_table :document_attachment
  end
end