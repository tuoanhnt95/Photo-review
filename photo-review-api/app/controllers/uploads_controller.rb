class UploadsController < ApplicationController
  before_action :set_upload, only: %i[ show update destroy ]

  # GET /uploads
  def index
    @uploads = Upload.all

    render json: @uploads
  end

  # GET /uploads/1
  def show
    render json: @upload
  end

  # POST /uploads
  def create
    @upload = Upload.new(upload_params)

    if @upload.save
      render json: @upload, status: :created, location: @upload
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /uploads/1
  def update
    if @upload.update(upload_params)
      render json: @upload
    else
      render json: @upload.errors, status: :unprocessable_entity
    end
  end

  # DELETE /uploads/1
  def destroy
    @upload.destroy
  end

  def increment_progress
    @upload = Upload.find_by(name: file.name, album_id: album_id)
    @upload.increment!(:progress)
    render json: @upload
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_upload
      @upload = Upload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def upload_params
      params.require(:upload).permit(:name, :progress, :album_id)
    end
end
