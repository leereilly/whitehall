class Admin::FeaturingsController < Admin::BaseController
  before_filter :load_document
  before_filter :ensure_document_is_featurable

  def create
    featuring_image = (params[:document] || {})[:featuring_image]
    unless @document.feature(featuring_image)
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def update
    unless @document.update_attributes(params[:document])
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def destroy
    unless @document.unfeature
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def load_document
    @document = Document.find(params[:document_id])
  end

  def ensure_document_is_featurable
    unless @document.featurable?
      redirect_to :back, alert: "#{@document.class.to_s.underscore.humanize.pluralize} cannot be featured"
    end
  end
end
