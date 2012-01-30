module Admin::DocumentActionsHelper
  def edit_document_button(document)
    link_to 'Edit', edit_admin_document_path(document), title: "Edit #{document.title}", class: "button"
  end

  def redraft_document_button(document)
    button_to 'Create new edition', revise_admin_document_path(document), title: "Create new edition"
  end

  def submit_document_button(document)
    capture do
      form_for [:admin, document], {url: submit_admin_document_path(document), method: :post} do |submit_form|
        concat(submit_form.submit "Submit to 2nd pair of eyes")
      end
    end
  end

  def publish_document_button(document)
    capture do
      form_for [:admin, document], {as: :document, url: admin_document_publishing_path(document), method: :post} do |form|
        concat(form.hidden_field :lock_version)
        submit_options = {title: "Publish #{document.title}"}
        if document.has_supporting_pages?
          submit_options[:confirm] = "Have you checked the #{document.supporting_pages.count} supporting pages?"
        end
        concat(form.submit "Publish", submit_options)
      end
    end
  end

  def force_publish_document_button(document)
    capture do
      form_for [:admin, document], {as: :document, url: admin_document_publishing_path(document, force: true), method: :post} do |form|
        concat(form.hidden_field :lock_version)
        submit_options = {title: "Publish #{document.title}"}
        if document.has_supporting_pages?
          submit_options[:confirm] = "Are you sure you want to force publish this document? Have you checked the #{document.supporting_pages.count} supporting pages?"
        else
          submit_options[:confirm] = "Are you sure you want to force publish this document?"
        end
        concat(form.submit "Force Publish", submit_options)
      end
    end
  end

  def delete_document_button(document)
    button_to 'Delete', admin_document_path(document), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?"
  end

  def show_or_add_consultation_response_button(consultation)
    if consultation.latest_consultation_response
      show_consultation_response_button(consultation)
    else
      add_consultation_response_button(consultation)
    end
  end

  def add_consultation_response_button(consultation)
    link_to 'Add response', new_admin_consultation_response_path(document: {consultation_id: consultation}), title: "Add response", class: "button"
  end

  def show_consultation_response_button(consultation)
    link_to 'Show response', admin_consultation_response_path(consultation.latest_consultation_response), title: "Show response", class: "button"
  end
end