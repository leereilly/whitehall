class MinisterialRolesController < PublicFacingController
  def index
    @cabinet_ministerial_roles = MinisterialRole.cabinet.includes(:current_people)
    @ministerial_roles = MinisterialRole.alphabetical_by_person.includes(:current_people) - @cabinet_ministerial_roles
  end

  def show
    @ministerial_role = MinisterialRole.find(params[:id])
    load_published_documents_in_scope { |scope| scope.in_ministerial_role(@ministerial_role).by_published_at }
    speeches = @ministerial_role.speeches.published

    @announcements = Announcement.by_first_published_at(@news_articles + speeches)
  end
end