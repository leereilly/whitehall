class Admin::EditorialRemarksController < Admin::BaseController
  def new
    @document = Document.find(params[:document_id])
    @editorial_remark = @document.editorial_remarks.build
  end

  def create
    @document = Document.find(params[:document_id])
    @editorial_remark = @document.editorial_remarks.build(params[:editorial_remark].merge(author: current_user))
    if @editorial_remark.save
      @document.reject!
      redirect_to submitted_admin_documents_path
    else
      render "new"
    end
  end
end