class PostsController < ApplicationController
  before_action :set_post, only: %i[ show update destroy ]
  skip_before_action :authenticate_user, only: [ :index, :show, :popular ]

  # GET /posts
  def index
    @posts = Post.includes(:tags)

    # 検索クエリによるフィルタリング
    if params[:search].present?
      search_query = params[:search].downcase.strip
      # タグを含む投稿を検索
      tag_posts = Post.joins(:tags).where("LOWER(tags.name) LIKE ?", "%#{search_query}%")
      # タイトル、説明、季節で検索
      text_posts = @posts.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(season) LIKE ?",
        "%#{search_query}%", "%#{search_query}%", "%#{search_query}%"
      )
      # 両方の結果を結合
      @posts = @posts.where(id: tag_posts.select(:id)).or(@posts.where(id: text_posts.select(:id)))
    end

    # 季節フィルター
    if params[:season].present?
      case params[:season]
      when "spring"
        @posts = @posts.where(season: [ "spring-summer", "spring" ])
      when "summer"
        @posts = @posts.where(season: [ "spring-summer", "summer" ])
      when "autumn"
        @posts = @posts.where(season: [ "autumn-winter", "autumn" ])
      when "winter"
        @posts = @posts.where(season: [ "autumn-winter", "winter" ])
      else
        @posts = @posts.where(season: params[:season])
      end
    end

    # 画像がある投稿のみフィルタリング（オプション）
    if params[:with_images] == "true"
      @posts = @posts.joins(:images_attachments).distinct
    end

    # ソートパラメータに応じて並び替え
    case params[:sort]
    when "popular"
      @posts = @posts.popular
    when "newest"
      @posts = @posts.order(created_at: :desc)
    else
      @posts = @posts.order(created_at: :desc) # デフォルトは新着順
    end

    # ページネーション
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 6
    @posts = @posts.offset((page - 1) * per_page).limit(per_page)

    posts_data = @posts.map do |post|
      Rails.logger.info "Post #{post.id}: images.attached? = #{post.images.attached?}, count = #{post.images.count}"
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end
      Rails.logger.info "Post #{post.id}: images = #{images}"

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    # 総件数を取得（ページネーション前）
    total_count = Post.includes(:tags)
    if params[:search].present?
      search_query = params[:search].downcase.strip
      # タグを含む投稿を検索
      tag_posts = Post.joins(:tags).where("LOWER(tags.name) LIKE ?", "%#{search_query}%")
      # タイトル、説明、季節で検索
      text_posts = total_count.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(season) LIKE ?",
        "%#{search_query}%", "%#{search_query}%", "%#{search_query}%"
      )
      # 両方の結果を結合
      total_count = total_count.where(id: tag_posts.select(:id)).or(total_count.where(id: text_posts.select(:id)))
    end
    if params[:season].present?
      case params[:season]
      when "spring"
        total_count = total_count.where(season: [ "spring-summer", "spring" ])
      when "summer"
        total_count = total_count.where(season: [ "spring-summer", "summer" ])
      when "autumn"
        total_count = total_count.where(season: [ "autumn-winter", "autumn" ])
      when "winter"
        total_count = total_count.where(season: [ "autumn-winter", "winter" ])
      else
        total_count = total_count.where(season: params[:season])
      end
    end
    if params[:with_images] == "true"
      total_count = total_count.joins(:images_attachments).distinct
    end

    render json: {
      posts: posts_data,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count.count,
        total_pages: (total_count.count.to_f / per_page).ceil
      }
    }
  end

  # GET /posts/my
  def my
    @posts = Post.includes(:tags).where(user_id: @current_user.id).order(created_at: :desc)

    # ページネーション
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 5
    @posts = @posts.offset((page - 1) * per_page).limit(per_page)

    posts_data = @posts.map do |post|
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    # 総件数を取得（ページネーション前）
    total_count = Post.where(user_id: @current_user.id).count

    render json: {
      posts: posts_data,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    }
  end

  # GET /posts/popular
  def popular
    # お気に入りが1件以上の投稿のみを対象
    @posts = Post.includes(:tags).where("favorites_count > 0").popular

    if params[:season].present?
      case params[:season]
      when "spring-summer"
        @posts = @posts.where(season: [ "spring-summer", "spring", "summer" ])
      when "autumn-winter"
        @posts = @posts.where(season: [ "autumn-winter", "autumn", "winter" ])
      else
        @posts = @posts.where(season: params[:season])
      end
    end

    # 画像がある投稿のみ（オプション）
    if params[:with_images] == "true"
      @posts = @posts.joins(:images_attachments).distinct
    end

    # 件数制限
    limit = params[:limit] ? params[:limit].to_i : 10
    @posts = @posts.limit(limit)

    posts_data = @posts.map do |post|
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    render json: posts_data
  end

  # GET /posts/1
  def show
    render json: @post.as_json.merge(
      images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
      tags: @post.tags.pluck(:name),
      favorites_count: @post.favorites_count
    )
  end

  # POST /posts
  def create
    @post = Post.new(post_params.except(:tags))
    @post.user_id = @current_user.id

    if @post.save
      # タグを個別に作成（重複を避ける）
      if params[:post][:tags].present?
        unique_tags = params[:post][:tags].uniq.reject(&:blank?).map(&:strip)
        unique_tags.each do |tag_name|
          @post.tags.find_or_create_by(name: tag_name) if tag_name.present?
        end
      end

      render json: @post.as_json.merge(
        images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
        tags: @post.tags.pluck(:name)
      ), status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    # 投稿の所有者のみ編集可能
    if @post.user_id != @current_user.id
      render json: { error: "You are not authorized to edit this post" }, status: :unauthorized
      return
    end

    if @post.update(post_params.except(:tags))
      # 既存のタグを削除
      @post.tags.destroy_all
      # 新しいタグを作成（重複を避ける）
      if params[:post][:tags].present?
        unique_tags = params[:post][:tags].uniq.reject(&:blank?).map(&:strip)
        unique_tags.each do |tag_name|
          @post.tags.find_or_create_by(name: tag_name) if tag_name.present?
        end
      end

      render json: @post.as_json.merge(
        images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
        tags: @post.tags.pluck(:name)
      )
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if @post.user_id == @current_user.id
      @post.destroy!
      render json: { message: "Post deleted successfully" }, status: :ok
    else
      render json: { error: "You are not authorized to delete this post" }, status: :unauthorized
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :price, :description, :season, :tags, images: [] ])
    end
end
