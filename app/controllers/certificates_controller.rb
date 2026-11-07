class CertificatesController < ApplicationController
  before_action :authenticate_user!

  def index
    @certificates = current_user.certificates.includes(:course).order(earned_at: :desc)
  end
end
