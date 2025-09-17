class FavoritesController < ApplicationController
  before_action :set_favorite, only: [ :destroy ]

  # お気に入り一覧を取得
  def index
    @favorites = Favorite.where(user_id: @current_user.id)
    render json: @favorites
  end

  # お気に入りを追加
  def create
    @favorite = Favorite.find_or_create_by(
      user_id: @current_user.id,
      post_id: params[:post_id]
    )

    if @favorite.persisted?
      render json: { message: "お気に入りに追加しました", favorite: @favorite }, status: :created
    else
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # お気に入りを削除
  def destroy
    if @favorite
      @favorite.destroy
      render json: { message: "お気に入りから削除しました" }
    else
      render json: { error: "お気に入りが見つかりません" }, status: :not_found
    end
  end

  # 特定の投稿がお気に入りかどうかをチェック
  def check
    @favorite = Favorite.find_by(
      user_id: @current_user.id,
      post_id: params[:post_id]
    )

    render json: { is_favorite: @favorite.present? }
  end

  private

  def set_favorite
    @favorite = Favorite.find_by(
      user_id: @current_user.id,
      post_id: params[:post_id]
    )
  end
end
