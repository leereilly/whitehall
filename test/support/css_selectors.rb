module CssSelectors
  include ActionController::RecordIdentifier

  def record_css_selector(object)
    '#' + dom_id(object)
  end

  def record_id_from(element)
    element["id"].split("_").last
  end

  def records_from_elements(klass, elements)
    klass.find(elements.map { |element| record_id_from(element) })
  end

  def organisations_selector
    "#organisations"
  end

  def policy_areas_selector
    "#policy_areas"
  end

  def ministers_responsible_selector
    "#ministers_responsible"
  end

  def supporting_pages_selector
    "#supporting_pages"
  end

  def metadata_nav_selector
    "p.meta"
  end

  def related_news_articles_selector
    "#related-news-articles"
  end

  def related_consultations_selector
    "#related-consultations"
  end

  def related_publications_selector
    "#related-publications"
  end

  def corporate_publications_selector
    "#corporate-publications"
  end

  def inapplicable_nations_selector
    "#inapplicable_nations"
  end

  def notes_to_editors_selector
    "#notes_to_editors"
  end

  def parent_organisations_list_selector
    "select[name='organisation[parent_organisation_ids][]']"
  end

  def organisation_type_list_selector
    "select[name='organisation[organisation_type_id]']"
  end

  def organisation_policy_areas_list_selector
    "select[name='organisation[policy_area_ids][]']"
  end

  def permanent_secretary_board_members_selector
    "#permanent_secretary_board_members"
  end

  def featured_news_articles_selector
    "#featured-news-articles"
  end

  def featured_consultations_selector
    "#featured-consultations"
  end

  def countries_selector
    "#countries"
  end

  def force_publish_button_selector(document)
    "form[action=#{admin_document_publishing_path(document, force: true)}]"
  end

  def reject_button_selector(document)
    "a[href=#{new_admin_document_editorial_remark_path(document)}]"
  end

  def link_to_public_version_selector
    ".actions .public_version"
  end
end