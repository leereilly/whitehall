module ApplicationHelper
  def page_title(*title_parts)
    if title_parts.any?
      title_parts.push("Admin") if params[:controller] =~ /^admin\//
      title_parts.push("Inside Government")
      title_parts.push("GOV.UK")
      @page_title = title_parts.join(" | ")
    else
      @page_title
    end
  end

  def show_session_controls?
    params[:controller].split("/").first == "admin" ||
    params[:controller] == "sessions"
  end

  def labelled_check_box(object_name, attribute, text)
    for_attribute = [object_name, attribute].map(&:to_s).join("_")
    label_tag "", {for: for_attribute, class: "for_checkbox"} do
      check_box(object_name, attribute) +
      "&nbsp;".html_safe +
      content_tag(:span, text)
    end
  end

  def format_in_paragraphs(string)
    safe_join (string||"").split(/(?:\r?\n){2}/).collect { |paragraph| content_tag(:p, paragraph) }
  end

  def format_with_html_line_breaks(string)
    (string||"").gsub(/(?:\r?\n)/, "<br/>").html_safe
  end

  def link_to_attachment(attachment)
    return unless attachment
    link_to attachment.filename, attachment.url
  end

  def publication_summary(publication)
    if publication.summary.present?
      publication.summary
    else
      truncate(publication.body, { length: 200 })
    end
  end

  def empty_documents_list_verb(document_state)
    if document_state.downcase == "draft"
      "drafted"
    else
      document_state.downcase
    end
  end

  def ministerial_appointment_options
    MinisterialRole.joins(:current_role_appointments).alphabetical_by_person.map do |role|
      [role.current_role_appointment.id, role.to_s]
    end
  end

  def image_for_ministerial_role(ministerial_role)
    url = ministerial_role.current_person_image_url || 'blank-person.png'
    url = "http://mustachify.me/?src=" + url if params[:plummy]
    image_tag url
  end

  def render_list_of_roles(roles, class_name = "ministerial_roles", &block)
    raise ArgumentError, "please supply the content of the list item" unless block_given?
    content_tag(:ul, class: class_name) do
      roles.each do |role|
        li = content_tag_for(:li, role) do
          block.call(role).html_safe
        end.html_safe
        concat li
      end
    end
  end

  def render_list_of_ministerial_roles(ministerial_roles, &block)
    render_list_of_roles(ministerial_roles, &block)
  end

  def link_to_with_current(name, path, options={})
    path_matcher = options.delete(:current_path) || Regexp.new("^#{Regexp.escape(path)}$")
    css_classes = [options[:class], current_link_class(path_matcher)].join(" ").strip
    options[:class] = css_classes unless css_classes.blank?

    link_to name, path, options
  end

  def current_link_class(path_matcher)
    request.path =~ path_matcher ? 'current' : ''
  end

  def human_friendly_document_type(document)
    document.type.tableize.singularize.humanize
  end

  def yes_or_no(boolean)
    boolean ? "Yes" : "No"
  end

  def render_datetime_microformat(object, method, &block)
    content_tag(:abbr, class: method, title: object.send(method).iso8601, &block)
  end

  def time_ago(time, options = {})
    css_class = (options[:class] || "") + " datetime time_ago"
    text = time.to_s(:long_ordinal)
    content_tag(:abbr, text, class: css_class, title: time.iso8601)
  end

  def main_navigation_link_to(name, path, html_options = {}, &block)
    classes = (html_options[:class] || "").split
    if current_main_navigation_path(params) == path
      classes << "current"
    end
    link_to(name, path, html_options.merge(class: classes.join(" ")), &block)
  end

  def current_main_navigation_path(parameters)
    case parameters[:controller]
    when "site"
      root_path
    when "announcements", "news_articles", "speeches"
      announcements_path
    when "policy_areas", "policies", "supporting_pages"
      policy_areas_path
    when "publications"
      publications_path
    when "consultations", "consultation_responses"
      open_consultations_path
    when "ministerial_roles"
      ministerial_roles_path
    when "organisations"
      organisations_path
    when "countries", "international_priorities"
      countries_path
    end
  end

  def featured_grid_class(count=0)
    case count
    when 1
      "g3f"
    when 2
      "g-half-flood"
    when 3
      "g1f"
    end
  end

  def article_section(title, collection, options = {}, &block)
    content_tag(:section, id: options[:id], class: "article_section") do
      concat content_tag(:h1, title)
      div = content_tag(:div, class: "group articles") do
        collection.each do |item|
          article = content_tag_for(:article, item) do
            block.call(item).html_safe
          end.html_safe
          concat article
        end
      end
      concat div
      concat content_tag(:p, options[:more], class: "readmore") if options[:more]
    end
  end
end
