require "test_helper"

class PhotoUserReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @photo_user_review = photo_user_reviews(:one)
  end

  test "should get index" do
    get photo_user_reviews_url, as: :json
    assert_response :success
  end

  test "should create photo_user_review" do
    assert_difference("PhotoUserReview.count") do
      post photo_user_reviews_url, params: { photo_user_review: {  } }, as: :json
    end

    assert_response :created
  end

  test "should show photo_user_review" do
    get photo_user_review_url(@photo_user_review), as: :json
    assert_response :success
  end

  test "should update photo_user_review" do
    patch photo_user_review_url(@photo_user_review), params: { photo_user_review: {  } }, as: :json
    assert_response :success
  end

  test "should destroy photo_user_review" do
    assert_difference("PhotoUserReview.count", -1) do
      delete photo_user_review_url(@photo_user_review), as: :json
    end

    assert_response :no_content
  end
end
