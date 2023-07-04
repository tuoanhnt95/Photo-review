class PhotoUserReviewsController < ApplicationController
  before_action :set_photo_user_review, only: %i[ show update destroy ]

  # GET /photo_user_reviews
  def index
    @photo_user_reviews = PhotoUserReview.all

    render json: @photo_user_reviews
  end

  # GET /photo_user_reviews/1
  def show
    render json: @photo_user_review
  end

  # POST /photo_user_reviews
  def create
    @photo_user_review = PhotoUserReview.new(photo_user_review_params)

    if @photo_user_review.save
      render json: @photo_user_review, status: :created, location: @photo_user_review
    else
      render json: @photo_user_review.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /photo_user_reviews/1
  def update
    if @photo_user_review.update(photo_user_review_params)
      render json: @photo_user_review
    else
      render json: @photo_user_review.errors, status: :unprocessable_entity
    end
  end

  # DELETE /photo_user_reviews/1
  def destroy
    @photo_user_review.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo_user_review
      @photo_user_review = PhotoUserReview.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_user_review_params
      params.fetch(:photo_user_review, {})
    end
end
