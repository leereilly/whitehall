module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym.present?
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_navigation_link_to(body, path)
    if (current_organisation_navigation_path(params) == path) ||
       (params[:action] == "management_team" && path == current_organisation_navigation_path(params.merge(action: "about")))
      css_class = 'current'
    else
      css_class = nil
    end

    link_to body, path, class: css_class
  end

  def current_organisation_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def organisation_view_all_tag(organisation, kind)
    path = send(:"#{kind}_organisation_path", @organisation)
    text = (kind == :announcements) ? "news & speeches" : kind
    content_tag(:span, safe_join(['View all', content_tag(:span, @organisation.name, class: "visuallyhidden"), link_to(text, path)], ' '), class: "view_all")
  end
end
