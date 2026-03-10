class RelationshipsController < ApplicationController
  skip_before_action :authenticate_user, only: [:followers, :following]

  # POST /relationships
  def create
    @relationship = Relationship.find_or_create_by(
      follower_id: @current_user.id,
      following_id: params[:following_id]
    )

    if @relationship.persisted?
      render json: { message: "フォローしました", relationship: @relationship }, status: :created
    else
      render json: { errors: @relationship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /relationships
  def destroy
    @relationship = Relationship.find_by(
      follower_id: @current_user.id,
      following_id: params[:following_id]
    )

    if @relationship
      @relationship.destroy
      render json: { message: "フォローを解除しました" }
    else
      render json: { error: "フォロー関係が見つかりません" }, status: :not_found
    end
  end

  # GET /relationships/check?following_id=:following_id
  def check
    @relationship = Relationship.find_by(
      follower_id: @current_user.id,
      following_id: params[:following_id]
    )

    render json: { is_following: @relationship.present? }
  end

  # GET /relationships/followers?user_id=:user_id
  def followers
    user = User.find(params[:user_id])
    followers_list = user.followers.select(:id, :name, :nickname, :selected_icon, :profile_image)

    render json: {
      followers: followers_list,
      count: user.followers_count
    }
  end

  # GET /relationships/following?user_id=:user_id
  def following
    user = User.find(params[:user_id])
    following_list = user.following.select(:id, :name, :nickname, :selected_icon, :profile_image)

    render json: {
      following: following_list,
      count: user.following_count
    }
  end
end
